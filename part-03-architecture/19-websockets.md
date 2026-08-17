# WebSocket والتواصل اللحظي (Real-time Communication)

## نظرة عامة

> **مجاني أثناء البناء:** Django Channels + Upstash Redis (Free) — يعمل بدون تكلفة إضافية.

نsystem للتواصل اللحظي يدعم: المحادثات، الإشعارات الفورية، تحديثات الحالة، والنشر المشترك.

---

## المكونات

```
┌─────────────────────────────────────────────────────────────────┐
│                    Real-time Stack                               │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  ┌──────────────────┐    ┌──────────────────┐                   │
│  │  Django Channels │    │  Redis (Channel  │                   │
│  │  (WebSocket)     │───►│  Layer)          │                   │
│  └──────────────────┘    └──────────────────┘                   │
│          │                       │                               │
│          ▼                       ▼                               │
│  ┌──────────────────┐    ┌──────────────────┐                   │
│  │  WebSocket       │    │  Consumers       │                   │
│  │  Server          │───►│  ( handlers)     │                   │
│  └──────────────────┘    └──────────────────┘                   │
│                                 │                               │
│                                 ▼                               │
│                          ┌──────────────────┐                   │
│                          │  Frontend        │                   │
│                          │  (React Hook)    │                   │
│                          └──────────────────┘                   │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

---

## Django Channels Configuration

```python
# config/asgi.py

import os
from django.core.asgi import get_asgi_application
from channels.routing import ProtocolTypeRouter, URLRouter
from channels.auth import AuthMiddlewareStack

os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'config.settings')

django_asgi_app = get_asgi_application()

from notifications.routing import websocket_urlpatterns

application = ProtocolTypeRouter({
    "http": django_asgi_app,
    "websocket": AuthMiddlewareStack(
        URLRouter(websocket_urlpatterns)
    ),
})
```

```python
# config/settings.py (إضافات)

INSTALLED_APPS = [
    ...
    'channels',
    'daphne',
]

ASGI_APPLICATION = 'config.asgi.application'

CHANNEL_LAYERS = {
    'default': {
        'BACKEND': 'channels_redis.core.RedisChannelLayer',
        'CONFIG': {
            'hosts': [('redis', 6379)],
            'capacity': 1500,
            'expiry': 10,
        },
    },
}
```

---

## WebSocket Consumers

```python
# notifications/consumers.py

import json
from channels.generic.websocket import AsyncWebSocketConsumer
from channels.db import database_sync_to_async
from channels_presence.models import Presence


class NotificationConsumer(AsyncWebSocketConsumer):
    """consumer الإشعارات"""
    
    async def connect(self):
        self.user = self.scope['user']
        
        if self.user.is_anonymous:
            await self.close()
            return
        
        # الانضمام لقناة المستخدم
        self.room_group_name = f'user_{self.user.id}'
        
        await self.channel_layer.group_add(
            self.room_group_name,
            self.channel_name
        )
        
        await self.accept()
        
        # تسجيل الحضور
        await self.add_presence()
    
    async def disconnect(self, close_code):
        if hasattr(self, 'room_group_name'):
            await self.channel_layer.group_discard(
                self.room_group_name,
                self.channel_name
            )
        
        # إزالة الحضور
        await self.remove_presence()
    
    async def receive(self, text_data):
        data = json.loads(text_data)
        
        if data.get('type') == 'mark_read':
            await self.mark_notification_read(data['notification_id'])
    
    # ─── Handlers ──────────────────────────────────────
    
    async def notification_message(self, event):
        """إرسال إشعار"""
        await self.send(text_data=json.dumps({
            'type': 'notification',
            'data': event['data'],
        }))
    
    async def lesson_update(self, event):
        """تحديث الدرس"""
        await self.send(text_data=json.dumps({
            'type': 'lesson_update',
            'data': event['data'],
        }))
    
    async def course_update(self, event):
        """تحديث الدورة"""
        await self.send(text_data=json.dumps({
            'type': 'course_update',
            'data': event['data'],
        }))
    
    async def typing_indicator(self, event):
        """مؤشر الكتابة"""
        await self.send(text_data=json.dumps({
            'type': 'typing',
            'data': event['data'],
        }))
    
    @database_sync_to_async
    def add_presence(self):
        Presence.objects.add(
            channel_name=self.channel_name,
            user=self.user,
        )
    
    @database_sync_to_async
    def remove_presence(self):
        Presence.objects.remove(self.channel_name)
    
    @database_sync_to_async
    def mark_notification_read(self, notification_id):
        from .models import Notification
        Notification.objects.filter(
            id=notification_id,
            user=self.user
        ).update(read=True)
```

```python
# notifications/consumers.py (محادثة)

class ChatConsumer(AsyncWebSocketConsumer):
    """consumer المحادثات"""
    
    async def connect(self):
        self.user = self.scope['user']
        self.room_name = self.scope['url_route']['kwargs']['room_name']
        self.room_group_name = f'chat_{self.room_name}'
        
        if self.user.is_anonymous:
            await self.close()
            return
        
        # التحقق من الصلاحية
        if not await self.can_access_room():
            await self.close()
            return
        
        await self.channel_layer.group_add(
            self.room_group_name,
            self.channel_name
        )
        
        await self.accept()
    
    async def disconnect(self, close_code):
        await self.channel_layer.group_discard(
            self.room_group_name,
            self.channel_name
        )
    
    async def receive(self, text_data):
        data = json.loads(text_data)
        
        if data['type'] == 'message':
            # حفظ الرسالة
            message = await self.save_message(data['message'])
            
            # إرسال للمجموعة
            await self.channel_layer.group_send(
                self.room_group_name,
                {
                    'type': 'chat_message',
                    'message': {
                        'id': message.id,
                        'content': message.content,
                        'sender': {
                            'id': self.user.id,
                            'name': self.user.name,
                            'avatar': self.user.avatar.url if self.user.avatar else None,
                        },
                        'created_at': message.created_at.isoformat(),
                    }
                }
            )
        
        elif data['type'] == 'typing':
            await self.channel_layer.group_send(
                self.room_group_name,
                {
                    'type': 'typing_indicator',
                    'data': {
                        'user_id': self.user.id,
                        'user_name': self.user.name,
                        'is_typing': data['is_typing'],
                    }
                }
            )
    
    async def chat_message(self, event):
        await self.send(text_data=json.dumps({
            'type': 'message',
            'data': event['message'],
        }))
    
    async def typing_indicator(self, event):
        if event['data']['user_id'] != self.user.id:
            await self.send(text_data=json.dumps({
                'type': 'typing',
                'data': event['data'],
            }))
    
    @database_sync_to_async
    def can_access_room(self):
        from .models import ChatRoom
        return ChatRoom.objects.filter(
            id=self.room_name,
            participants=self.user
        ).exists()
    
    @database_sync_to_async
    def save_message(self, content):
        from .models import ChatMessage, ChatRoom
        
        room = ChatRoom.objects.get(id=self.room_name)
        
        return ChatMessage.objects.create(
            room=room,
            sender=self.user,
            content=content,
        )
```

```python
# notifications/consumers.py (معلم/طالب مباشر)

class LiveClassConsumer(AsyncWebSocketConsumer):
    """consumer الحصص المباشرة"""
    
    async def connect(self):
        self.user = self.scope['user']
        self.class_id = self.scope['url_route']['kwargs']['class_id']
        self.room_group_name = f'live_class_{self.class_id}'
        
        if self.user.is_anonymous:
            await self.close()
            return
        
        # التحقق من الصلاحية
        if not await self.can_access_class():
            await self.close()
            return
        
        await self.channel_layer.group_add(
            self.room_group_name,
            self.channel_name
        )
        
        await self.accept()
        
        # إعلام الآخرين بالدخول
        await self.channel_layer.group_send(
            self.room_group_name,
            {
                'type': 'user_joined',
                'data': {
                    'user_id': self.user.id,
                    'user_name': self.user.name,
                }
            }
        )
    
    async def disconnect(self, close_code):
        # إعلام الآخرين بالخروج
        await self.channel_layer.group_send(
            self.room_group_name,
            {
                'type': 'user_left',
                'data': {
                    'user_id': self.user.id,
                    'user_name': self.user.name,
                }
            }
        )
        
        await self.channel_layer.group_discard(
            self.room_group_name,
            self.channel_name
        )
    
    async def receive(self, text_data):
        data = json.loads(text_data)
        
        if data['type'] == 'question':
            await self.channel_layer.group_send(
                self.room_group_name,
                {
                    'type': 'new_question',
                    'data': {
                        'user_id': self.user.id,
                        'user_name': self.user.name,
                        'question': data['question'],
                    }
                }
            )
        
        elif data['type'] == 'answer':
            await self.channel_layer.group_send(
                self.room_group_name,
                {
                    'type': 'question_answered',
                    'data': {
                        'question_id': data['question_id'],
                        'answer': data['answer'],
                        'answered_by': self.user.name,
                    }
                }
            )
        
        elif data['type'] == 'poll_vote':
            await self.handle_poll_vote(data)
    
    async def new_question(self, event):
        await self.send(text_data=json.dumps({
            'type': 'question',
            'data': event['data'],
        }))
    
    async def question_answered(self, event):
        await self.send(text_data=json.dumps({
            'type': 'answer',
            'data': event['data'],
        }))
    
    @database_sync_to_async
    def can_access_class(self):
        from academics.models import LiveClass
        live_class = LiveClass.objects.get(id=self.class_id)
        return (
            live_class.teacher == self.user or
            live_class.students.filter(id=self.user.id).exists()
        )
```

---

## WebSocket URLs

```python
# notifications/routing.py

from django.urls import re_path
from . import consumers

websocket_urlpatterns = [
    re_path(r'ws/notifications/$', consumers.NotificationConsumer.as_asgi()),
    re_path(r'ws/chat/(?P<room_name>\w+)/$', consumers.ChatConsumer.as_asgi()),
    re_path(r'ws/live-class/(?P<class_id>\w+)/$', consumers.LiveClassConsumer.as_asgi()),
]
```

---

## React Hooks

```typescript
// hooks/useWebSocket.ts

'use client';

import { useEffect, useRef, useCallback, useState } from 'react';

interface UseWebSocketOptions {
  onMessage?: (data: any) => void;
  onConnect?: () => void;
  onDisconnect?: () => void;
  reconnectAttempts?: number;
  reconnectInterval?: number;
}

export function useWebSocket(url: string, options: UseWebSocketOptions = {}) {
  const {
    onMessage,
    onConnect,
    onDisconnect,
    reconnectAttempts = 5,
    reconnectInterval = 3000,
  } = options;

  const ws = useRef<WebSocket | null>(null);
  const [isConnected, setIsConnected] = useState(false);
  const [lastMessage, setLastMessage] = useState<any>(null);
  const reconnectCount = useRef(0);

  const connect = useCallback(() => {
    try {
      const token = localStorage.getItem('access_token');
      ws.current = new WebSocket(`${url}?token=${token}`);

      ws.current.onopen = () => {
        setIsConnected(true);
        reconnectCount.current = 0;
        onConnect?.();
      };

      ws.current.onmessage = (event) => {
        const data = JSON.parse(event.data);
        setLastMessage(data);
        onMessage?.(data);
      };

      ws.current.onclose = () => {
        setIsConnected(false);
        onDisconnect?.();
        
        // إعادة محاولة الاتصال
        if (reconnectCount.current < reconnectAttempts) {
          setTimeout(() => {
            reconnectCount.current++;
            connect();
          }, reconnectInterval);
        }
      };

      ws.current.onerror = (error) => {
        console.error('WebSocket error:', error);
      };
    } catch (error) {
      console.error('WebSocket connection failed:', error);
    }
  }, [url, onMessage, onConnect, onDisconnect, reconnectAttempts, reconnectInterval]);

  useEffect(() => {
    connect();

    return () => {
      ws.current?.close();
    };
  }, [connect]);

  const sendMessage = useCallback((data: any) => {
    if (ws.current?.readyState === WebSocket.OPEN) {
      ws.current.send(JSON.stringify(data));
    }
  }, []);

  return {
    isConnected,
    lastMessage,
    sendMessage,
  };
}
```

```typescript
// hooks/useNotifications.ts

'use client';

import { useWebSocket } from './useWebSocket';
import { useState, useCallback } from 'react';

interface Notification {
  id: string;
  type: string;
  title: string;
  message: string;
  read: boolean;
  created_at: string;
}

export function useNotifications() {
  const [notifications, setNotifications] = useState<Notification[]>([]);
  const [unreadCount, setUnreadCount] = useState(0);

  const handleNotification = useCallback((data: any) => {
    if (data.type === 'notification') {
      setNotifications(prev => [data.data, ...prev]);
      setUnreadCount(prev => prev + 1);
    }
  }, []);

  const { isConnected, sendMessage } = useWebSocket(
    `${process.env.NEXT_PUBLIC_WS_URL}/ws/notifications/`,
    { onMessage: handleNotification }
  );

  const markAsRead = useCallback((notificationId: string) => {
    sendMessage({
      type: 'mark_read',
      notification_id: notificationId,
    });
    
    setNotifications(prev =>
      prev.map(n =>
        n.id === notificationId ? { ...n, read: true } : n
      )
    );
    setUnreadCount(prev => Math.max(0, prev - 1));
  }, [sendMessage]);

  return {
    notifications,
    unreadCount,
    isConnected,
    markAsRead,
  };
}
```

```typescript
// hooks/useChat.ts

'use client';

import { useWebSocket } from './useWebSocket';
import { useState, useCallback } from 'react';

interface ChatMessage {
  id: string;
  content: string;
  sender: {
    id: string;
    name: string;
    avatar?: string;
  };
  created_at: string;
}

export function useChat(roomName: string) {
  const [messages, setMessages] = useState<ChatMessage[]>([]);
  const [typingUsers, setTypingUsers] = useState<string[]>([]);

  const handleMessage = useCallback((data: any) => {
    switch (data.type) {
      case 'message':
        setMessages(prev => [...prev, data.data]);
        break;
      case 'typing':
        if (data.data.is_typing) {
          setTypingUsers(prev => [...prev, data.data.user_name]);
        } else {
          setTypingUsers(prev => prev.filter(name => name !== data.data.user_name));
        }
        break;
    }
  }, []);

  const { isConnected, sendMessage } = useWebSocket(
    `${process.env.NEXT_PUBLIC_WS_URL}/ws/chat/${roomName}/`,
    { onMessage: handleMessage }
  );

  const sendMessage = useCallback((content: string) => {
    sendMessage({ type: 'message', message: content });
  }, [sendMessage]);

  const setTyping = useCallback((isTyping: boolean) => {
    sendMessage({ type: 'typing', is_typing: isTyping });
  }, [sendMessage]);

  return {
    messages,
    typingUsers,
    isConnected,
    sendMessage,
    setTyping,
  };
}
```

---

## ملخص

> **WebSocket والتواصل اللحظي** يدعم: الإشعارات الفورية، المحادثات، الحصص المباشرة، مؤشرات الكتابة، وتحديثات الحالة. يستخدم Django Channels + Redis Channel Layer مع React Hooks.
