# تكامل الموبايل مع Backend

## Authentication

```typescript
// lib/auth.ts
import * as SecureStore from 'expo-secure-store';

export const tokenStorage = {
  async getAccessToken(): Promise<string | null> {
    return await SecureStore.getItemAsync('access_token');
  },
  
  async getRefreshToken(): Promise<string | null> {
    return await SecureStore.getItemAsync('refresh_token');
  },
  
  async setTokens(access: string, refresh: string): Promise<void> {
    await SecureStore.setItemAsync('access_token', access);
    await SecureStore.setItemAsync('refresh_token', refresh);
  },
  
  async clearTokens(): Promise<void> {
    await SecureStore.deleteItemAsync('access_token');
    await SecureStore.deleteItemAsync('refresh_token');
  }
};
```

---

## API Client

```typescript
// lib/api.ts
import axios from 'axios';
import { tokenStorage } from './auth';

const API_URL = process.env.EXPO_PUBLIC_API_URL || 'https://afaq.app/api/v1';

export const apiClient = axios.create({
  baseURL: API_URL,
  headers: {
    'Content-Type': 'application/json',
  },
});

// Request interceptor - إضافة التوكن
apiClient.interceptors.request.use(
  async (config) => {
    const token = await tokenStorage.getAccessToken();
    if (token) {
      config.headers.Authorization = `Bearer ${token}`;
    }
    return config;
  },
  (error) => Promise.reject(error)
);

// Response interceptor - تجديد التوكن
apiClient.interceptors.response.use(
  (response) => response,
  async (error) => {
    const originalRequest = error.config;
    
    if (error.response?.status === 401 && !originalRequest._retry) {
      originalRequest._retry = true;
      
      try {
        const refreshToken = await tokenStorage.getRefreshToken();
        const response = await axios.post(`${API_URL}/auth/refresh/`, {
          refresh: refreshToken,
        });
        
        const { access } = response.data;
        await tokenStorage.setTokens(access, refreshToken!);
        
        originalRequest.headers.Authorization = `Bearer ${access}`;
        return apiClient(originalRequest);
      } catch (refreshError) {
        await tokenStorage.clearTokens();
        // إعادة توجيه لشاشة تسجيل الدخول
        throw refreshError;
      }
    }
    
    return Promise.reject(error);
  }
);
```

---

## API Calls

```typescript
// lib/api/lesson-plans.ts
import { apiClient } from '../api';

export const lessonPlanApi = {
  async generate(data: GenerateLessonPlanRequest) {
    const response = await apiClient.post('/lesson-plans/generate/', data);
    return response.data;
  },
  
  async list(params?: LessonPlanParams) {
    const response = await apiClient.get('/lesson-plans/', { params });
    return response.data;
  },
  
  async get(id: number) {
    const response = await apiClient.get(`/lesson-plans/${id}/`);
    return response.data;
  },
  
  async update(id: number, data: UpdateLessonPlanRequest) {
    const response = await apiClient.put(`/lesson-plans/${id}/`, data);
    return response.data;
  },
  
  async delete(id: number) {
    await apiClient.delete(`/lesson-plans/${id}/`);
  },
  
  async duplicate(id: number) {
    const response = await apiClient.post(`/lesson-plans/${id}/duplicate/`);
    return response.data;
  },
  
  async exportPdf(id: number) {
    const response = await apiClient.post(`/lesson-plans/${id}/export/`);
    return response.data;
  }
};
```

---

## Push Notifications

```typescript
// lib/notifications.ts
import * as Notifications from 'expo-notifications';
import { apiClient } from './api';

export const notificationService = {
  async registerForPushNotifications() {
    const { status: existingStatus } = await Notifications.getPermissionsAsync();
    let finalStatus = existingStatus;
    
    if (existingStatus !== 'granted') {
      const { status } = await Notifications.requestPermissionsAsync();
      finalStatus = status;
    }
    
    if (finalStatus !== 'granted') {
      return null;
    }
    
    const token = await Notifications.getExpoPushTokenAsync();
    
    // حفظ التوكن في Backend
    await apiClient.post('/notifications/register-device/', {
      token: token.data,
      platform: Platform.OS,
    });
    
    return token.data;
  },
  
  setupNotificationHandlers() {
    Notifications.setNotificationHandler({
      handleNotification: async () => ({
        shouldShowAlert: true,
        shouldPlaySound: true,
        shouldSetBadge: true,
      }),
    });
  }
};
```

---

## Offline Support (مستقبلاً)

```typescript
// lib/offline.ts
import AsyncStorage from '@react-native-async-storage/async-storage';

export const offlineStorage = {
  async saveLessonPlan(plan: LessonPlan) {
    const plans = await this.getLessonPlans();
    plans.push(plan);
    await AsyncStorage.setItem('lesson_plans', JSON.stringify(plans));
  },
  
  async getLessonPlans(): Promise<LessonPlan[]> {
    const data = await AsyncStorage.getItem('lesson_plans');
    return data ? JSON.parse(data) : [];
  },
  
  async syncWithServer() {
    // مزامنة البيانات المخزنة محلياً مع الخادم
    const localPlans = await this.getLessonPlans();
    // ... sync logic
  }
};
```
