# نظام Gamification

## نظرة عامة

نظام شامل لتحفيز المستخدمين عبر النقاط، الشارات، الإنجازات، لوحة المتصدرين، والتحديات.

---

## المكونات

```
┌─────────────────────────────────────────────────────────────────┐
│                      نظام Gamification                           │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  ┌──────────────────┐    ┌──────────────────┐                   │
│  │  Points System   │    │  Badge System    │                   │
│  │  (نقاط)          │    │  (شارات)         │                   │
│  └──────────────────┘    └──────────────────┘                   │
│                                                                  │
│  ┌──────────────────┐    ┌──────────────────┐                   │
│  │  Achievements    │    │  Leaderboard     │                   │
│  │  (إنجازات)       │    │  (لوحة متصدرين)  │                   │
│  └──────────────────┘    └──────────────────┘                   │
│                                                                  │
│  ┌──────────────────┐    ┌──────────────────┐                   │
│  │  Challenges      │    │  Rewards         │                   │
│  │  (تحديات)        │    │  (مكافآت)        │                   │
│  └──────────────────┘    └──────────────────┘                   │
│                                                                  │
│  ┌──────────────────┐    ┌──────────────────┐                   │
│  │  Streaks         │    │  Levels          │                   │
│  │  (سلسلة يومية)   │    │  (مستويات)       │                   │
│  └──────────────────┘    └──────────────────┘                   │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

---

## نظام النقاط

```python
# gamification/points.py


class PointsManager:
    """مدير النقاط"""
    
    # نقاط كل نشاط
    POINTS = {
        # الأنشطة التعليمية
        'lesson_complete': 10,
        'quiz_perfect': 25,
        'quiz_pass': 15,
        'course_complete': 100,
        'course_review': 5,
        
        # الأنشطة الاجتماعية
        'daily_login': 5,
        'consecutive_days_3': 15,
        'consecutive_days_7': 35,
        'consecutive_days_30': 100,
        
        # المحتوى
        'blog_post': 20,
        'blog_comment': 2,
        'helpful_answer': 10,
        
        # السوق
        'product_upload': 15,
        'first_sale': 50,
        'sale': 10,
        
        # الإنجازات
        'badge_earned': 25,
        'level_up': 50,
        'challenge_complete': 75,
    }
    
    @classmethod
    def award_points(cls, user, activity: str, multiplier: float = 1.0) -> dict:
        """منح نقاط"""
        
        base_points = cls.POINTS.get(activity, 0)
        earned_points = int(base_points * multiplier)
        
        if earned_points <= 0:
            return {'success': False, 'reason': 'نشاط غير معروف'}
        
        # تحديث النقاط
        user.gamification.points += earned_points
        user.gamification.total_earned += earned_points
        user.gamification.save()
        
        # تسجيل المعاملة
        PointsTransaction.objects.create(
            user=user,
            activity=activity,
            points=earned_points,
            multiplier=multiplier,
        )
        
        # فحص المستوى الجديد
        new_level = cls.check_level_up(user)
        
        return {
            'success': True,
            'points_earned': earned_points,
            'total_points': user.gamification.points,
            'new_level': new_level,
        }
    
    @classmethod
    def check_level_up(cls, user) -> dict | None:
        """فحص رفع المستوى"""
        
        current_level = user.gamification.level
        next_level = Level.objects.filter(
            points_required__gt=current_level.points_required
        ).order_by('points_required').first()
        
        if next_level and user.gamification.total_earned >= next_level.points_required:
            user.gamification.level = next_level
            user.gamification.save()
            
            # منح نقاط المستوى الجديد
            cls.award_points(user, 'level_up')
            
            # إرسال إشعار
            send_level_up_notification(user, next_level)
            
            return {
                'level': next_level.number,
                'name': next_level.name,
                'rewards': next_level.rewards,
            }
        
        return None
    
    @classmethod
    def deduct_points(cls, user, points: int, reason: str) -> bool:
        """خصم نقاط"""
        
        if user.gamification.points < points:
            return False
        
        user.gamification.points -= points
        user.gamification.save()
        
        PointsTransaction.objects.create(
            user=user,
            activity=f'deduct_{reason}',
            points=-points,
        )
        
        return True
```

---

## نظام الشارات (Badges)

```python
# gamification/badges.py


class BadgeCategory(models.Model):
    """فئة الشارة"""
    
    name = models.CharField(max_length=100)
    name_en = models.CharField(max_length=100)
    description = models.TextField(blank=True)
    icon = models.CharField(max_length=50)
    color = models.CharField(max_length=7, default='#3B82F6')
    
    class Meta:
        verbose_name = 'فئة شارة'
        verbose_name_plural = 'فئات الشارات'


class Badge(models.Model):
    """الشارة"""
    
    class Rarity(models.TextChoices):
        COMMON = 'common', 'شائعة'
        UNCOMMON = 'uncommon', 'غير شائعة'
        RARE = 'rare', 'نادرة'
        EPIC = 'epic', 'ملحمية'
        LEGENDARY = 'legendary', 'أسطورية'
    
    name = models.CharField(max_length=100)
    name_en = models.CharField(max_length=100)
    description = models.TextField()
    description_en = models.TextField(blank=True)
    
    category = models.ForeignKey(BadgeCategory, on_delete=models.CASCADE)
    
    icon = models.CharField(max_length=50)
    image = models.ImageField(upload_to='badges/')
    
    rarity = models.CharField(max_length=15, choices=Rarity.choices)
    points = models.IntegerField(default=0)
    
    # شروط الحصول
    requirement_type = models.CharField(max_length=50)
    requirement_value = models.IntegerField(default=1)
    
    # التوفر
    is_active = models.BooleanField(default=True)
    is_hidden = models.BooleanField(default=False)
    
    # الإحصائيات
    total_earned = models.IntegerField(default=0)
    
    created_at = models.DateTimeField(auto_now_add=True)
    
    class Meta:
        verbose_name = 'شارة'
        verbose_name_plural = 'الشارات'
        ordering = ['rarity', 'name']
    
    def __str__(self):
        return f"{self.name} ({self.get_rarity_display()})"


class UserBadge(models.Model):
    """شارة المستخدم"""
    
    user = models.ForeignKey('users.User', on_delete=models.CASCADE, related_name='badges')
    badge = models.ForeignKey(Badge, on_delete=models.CASCADE)
    
    earned_at = models.DateTimeField(auto_now_add=True)
    seen = models.BooleanField(default=False)
    
    class Meta:
        verbose_name = 'شارة مستخدم'
        verbose_name_plural = 'شارات المستخدمين'
        unique_together = ['user', 'badge']
```

---

## نظام الإنجازات (Achievements)

```python
# gamification/achievements.py


class Achievement(models.Model):
    """الإنجاز"""
    
    class Type(models.TextChoices):
        SINGLE = 'single', 'إنجاز واحد'
        PROGRESS = 'progress', 'إنجاز تدريجي'
        SECRET = 'secret', 'إنجاز سري'
    
    name = models.CharField(max_length=100)
    name_en = models.CharField(max_length=100)
    description = models.TextField()
    description_en = models.TextField(blank=True)
    
    type = models.CharField(max_length=15, choices=Type.choices)
    
    # شروط الإنجاز
    requirement = models.JSONField()
    # مثال: {"type": "lessons_completed", "count": 50}
    
    # المكافآت
    points_reward = models.IntegerField(default=0)
    badge_reward = models.ForeignKey(Badge, null=True, blank=True, on_delete=models.SET_NULL)
    
    # التوفر
    is_active = models.BooleanField(default=True)
    is_secret = models.BooleanField(default=False)
    
    # الإحصائيات
    total_earned = models.IntegerField(default=0)
    
    created_at = models.DateTimeField(auto_now_add=True)
    
    class Meta:
        verbose_name = 'إنجاز'
        verbose_name_plural = 'الإنجازات'
        ordering = ['name']


class UserAchievement(models.Model):
    """إنجاز المستخدم"""
    
    user = models.ForeignKey('users.User', on_delete=models.CASCADE, related_name='achievements')
    achievement = models.ForeignKey(Achievement, on_delete=models.CASCADE)
    
    # للإنجازات التدريجية
    progress = models.IntegerField(default=0)
    target = models.IntegerField(default=1)
    
    # الحالة
    completed = models.BooleanField(default=False)
    completed_at = models.DateTimeField(null=True, blank=True)
    
    class Meta:
        verbose_name = 'إنجاز مستخدم'
        verbose_name_plural = 'إنجازات المستخدمين'
        unique_together = ['user', 'achievement']
    
    @property
    def percentage(self) -> float:
        """نسبة الإكمال"""
        if self.target == 0:
            return 0
        return (self.progress / self.target) * 100
```

---

## نظام التحديات (Challenges)

```python
# gamification/challenges.py


class Challenge(models.Model):
    """التحدي"""
    
    class Duration(models.TextChoices):
        DAILY = 'daily', 'يومي'
        WEEKLY = 'weekly', 'أسبوعي'
        MONTHLY = 'monthly', 'شهري'
        SPECIAL = 'special', 'خاص'
    
    name = models.CharField(max_length=100)
    name_en = models.CharField(max_length=100)
    description = models.TextField()
    description_en = models.TextField(blank=True)
    
    duration = models.CharField(max_length=15, choices=Duration.choices)
    
    # المطلوب
    requirement = models.JSONField()
    # مثال: {"type": "lessons_completed", "count": 5}
    
    # المكافآت
    points_reward = models.IntegerField(default=0)
    badge_reward = models.ForeignKey(Badge, null=True, blank=True, on_delete=models.SET_NULL)
    
    # التوفر
    start_date = models.DateTimeField()
    end_date = models.DateTimeField()
    is_active = models.BooleanField(default=True)
    
    # الحد الأقصى للمشاركين
    max_participants = models.IntegerField(null=True, blank=True)
    
    created_at = models.DateTimeField(auto_now_add=True)
    
    class Meta:
        verbose_name = 'تحدي'
        verbose_name_plural = 'التحديات'
        ordering = ['-start_date']
    
    @property
    def is_ongoing(self) -> bool:
        """هل التحدي جارٍ؟"""
        now = timezone.now()
        return self.start_date <= now <= self.end_date
    
    @property
    def participants_count(self) -> int:
        """عدد المشاركين"""
        return self.participants.count()


class ChallengeParticipant(models.Model):
    """مشارك في التحدي"""
    
    challenge = models.ForeignKey(Challenge, on_delete=models.CASCADE, related_name='participants')
    user = models.ForeignKey('users.User', on_delete=models.CASCADE, related_name='challenges')
    
    # التقدم
    progress = models.IntegerField(default=0)
    target = models.IntegerField(default=1)
    
    # الحالة
    completed = models.BooleanField(default=False)
    completed_at = models.DateTimeField(null=True, blank=True)
    
    # الترتيب
    rank = models.IntegerField(null=True, blank=True)
    
    joined_at = models.DateTimeField(auto_now_add=True)
    
    class Meta:
        verbose_name = 'مشارك في تحدي'
        verbose_name_plural = 'المشاركون في التحديات'
        unique_together = ['challenge', 'user']
    
    @property
    def percentage(self) -> float:
        """نسبة الإكمال"""
        if self.target == 0:
            return 0
        return (self.progress / self.target) * 100
```

---

## نظام السلاسل اليومية (Streaks)

```python
# gamification/streaks.py


class UserStreak(models.Model):
    """سلسلة المستخدم اليومية"""
    
    user = models.OneToOneField('users.User', on_delete=models.CASCADE, related_name='streak')
    
    current_streak = models.IntegerField(default=0)
    longest_streak = models.IntegerField(default=0)
    last_activity_date = models.DateField(null=True, blank=True)
    
    # مكافآت السلاسل
    streak_rewards_claimed = models.JSONField(default=list)
    
    class Meta:
        verbose_name = 'سلسلة مستخدم'
        verbose_name_plural = 'سلاسل المستخدمين'
    
    def record_activity(self):
        """تسجيل نشاط يومي"""
        
        today = timezone.now().date()
        
        if self.last_activity_date == today:
            # تم التسجيل بالفعل اليوم
            return False
        
        if self.last_activity_date == today - timedelta(days=1):
            # متابعة السلاسل
            self.current_streak += 1
        else:
            # إعادة تعيين السلاسل
            self.current_streak = 1
        
        self.last_activity_date = today
        
        # تحديث أطول سلسلة
        if self.current_streak > self.longest_streak:
            self.longest_streak = self.current_streak
        
        self.save()
        
        # فحص مكافآت السلاسل
        self.check_streak_rewards()
        
        return True
    
    def check_streak_rewards(self):
        """فحص مكافآت السلاسل"""
        
        streak_milestones = [3, 7, 14, 30, 60, 90, 180, 365]
        
        for milestone in streak_milestones:
            if (self.current_streak >= milestone and 
                milestone not in self.streak_rewards_claimed):
                
                # منح المكافأة
                PointsManager.award_points(
                    self.user,
                    f'consecutive_days_{milestone}'
                )
                
                # تسجيل المكافأة
                self.streak_rewards_claimed.append(milestone)
                self.save()
                
                # إرسال إشعار
                send_streak_reward_notification(self.user, milestone)
```

---

## لوحة المتصدرين (Leaderboard)

```python
# gamification/leaderboard.py


class Leaderboard(models.Model):
    """لوحة المتصدرين"""
    
    class Period(models.TextChoices):
        DAILY = 'daily', 'يومي'
        WEEKLY = 'weekly', 'أسبوعي'
        MONTHLY = 'monthly', 'شهري'
        ALL_TIME = 'all_time', 'كل الأوقات'
    
    class Category(models.TextChoices):
        POINTS = 'points', 'النقاط'
        COURSES = 'courses', 'الدورات المكتملة'
        STREAK = 'streak', 'أطول سلسلة'
        BADGES = 'badges', 'الشارات'
    
    period = models.CharField(max_length=15, choices=Period.choices)
    category = models.CharField(max_length=15, choices=Category.choices)
    
    # بيانات محسنة
    entries = models.JSONField(default=list)
    # [{"user_id": 1, "name": "أحمد", "score": 1500, "rank": 1}]
    
    updated_at = models.DateTimeField(auto_now=True)
    
    class Meta:
        verbose_name = 'لوحة متصدرين'
        verbose_name_plural = 'لوائح المتصدرين'
        unique_together = ['period', 'category']
    
    @classmethod
    def update_leaderboard(cls, period: str, category: str):
        """تحديث لوحة المتصدرين"""
        
        if category == 'points':
            entries = cls._get_points_leaderboard(period)
        elif category == 'courses':
            entries = cls._get_courses_leaderboard(period)
        elif category == 'streak':
            entries = cls._get_streak_leaderboard()
        elif category == 'badges':
            entries = cls._get_badges_leaderboard()
        else:
            entries = []
        
        # ترتيب và تحديد الترتيب
        entries.sort(key=lambda x: x['score'], reverse=True)
        for i, entry in enumerate(entries):
            entry['rank'] = i + 1
        
        # حفظ
        board, _ = cls.objects.update_or_create(
            period=period,
            category=category,
            defaults={'entries': entries[:100]},  # أفضل 100
        )
        
        return board
    
    @classmethod
    def _get_points_leaderboard(cls, period: str) -> list:
        """لوحة النقاط"""
        
        if period == 'daily':
            start_date = timezone.now().date()
        elif period == 'weekly':
            start_date = timezone.now().date() - timedelta(days=7)
        elif period == 'monthly':
            start_date = timezone.now().date() - timedelta(days=30)
        else:
            start_date = None
        
        transactions = PointsTransaction.objects.all()
        
        if start_date:
            transactions = transactions.filter(created_at__date__gte=start_date)
        
        user_points = transactions.values('user_id').annotate(
            total=Sum('points')
        ).order_by('-total')[:100]
        
        entries = []
        for item in user_points:
            user = User.objects.get(id=item['user_id'])
            entries.append({
                'user_id': user.id,
                'name': user.name,
                'avatar': user.avatar.url if user.avatar else None,
                'score': item['total'],
            })
        
        return entries
    
    @classmethod
    def get_user_rank(cls, user_id: int, period: str, category: str) -> dict:
        """ترتيب المستخدم"""
        
        board = cls.objects.filter(period=period, category=category).first()
        
        if not board:
            return {'rank': None, 'total': 0}
        
        for entry in board.entries:
            if entry['user_id'] == user_id:
                return {
                    'rank': entry['rank'],
                    'score': entry['score'],
                    'total': len(board.entries),
                }
        
        return {'rank': None, 'total': len(board.entries)}
```

---

## نظام المستويات (Levels)

```python
# gamification/levels.py


class Level(models.Model):
    """المستوى"""
    
    number = models.IntegerField(unique=True)
    name = models.CharField(max_length=100)
    name_en = models.CharField(max_length=100)
    
    points_required = models.IntegerField()
    
    # المكافآت
    badge_reward = models.ForeignKey(Badge, null=True, blank=True, on_delete=models.SET_NULL)
    benefits = models.JSONField(default=list)
    # مثال: ["وصول لدورات متقدمة", "دعم أولوية"]
    
    # الصورة
    icon = models.CharField(max_length=50)
    color = models.CharField(max_length=7, default='#3B82F6')
    
    class Meta:
        verbose_name = 'مستوى'
        verbose_name_plural = 'المستويات'
        ordering = ['number']
    
    def __str__(self):
        return f"Level {self.number}: {self.name}"
```

---

## React Components

### مكون النقاط

```typescript
// components/gamification/PointsDisplay.tsx

'use client';

import { useGamification } from '@/hooks/useGamification';

interface PointsDisplayProps {
  showBreakdown?: boolean;
}

export function PointsDisplay({ showBreakdown = false }: PointsDisplayProps) {
  const { points, level, streak } = useGamification();

  return (
    <div className="bg-gradient-to-r from-blue-500 to-purple-600 rounded-lg p-6 text-white">
      <div className="flex items-center justify-between">
        <div>
          <p className="text-sm opacity-80">النقاط</p>
          <p className="text-3xl font-bold">{points.total.toLocaleString('ar')}</p>
        </div>
        
        <div className="text-left">
          <p className="text-sm opacity-80">المستوى</p>
          <p className="text-2xl font-bold">{level.name}</p>
        </div>
      </div>
      
      {showBreakdown && (
        <div className="mt-4 pt-4 border-t border-white/20">
          <div className="grid grid-cols-3 gap-4 text-center">
            <div>
              <p className="text-xs opacity-80">اليوم</p>
              <p className="font-semibold">+{points.today}</p>
            </div>
            <div>
              <p className="text-xs opacity-80">هذا الأسبوع</p>
              <p className="font-semibold">+{points.thisWeek}</p>
            </div>
            <div>
              <p className="text-xs opacity-80">هذا الشهر</p>
              <p className="font-semibold">+{points.thisMonth}</p>
            </div>
          </div>
        </div>
      )}
      
      {/* شريط التقدم للمستوى التالي */}
      <div className="mt-4">
        <div className="flex justify-between text-xs mb-1">
          <span>المستوى {level.number}</span>
          <span>المستوى {level.number + 1}</span>
        </div>
        <div className="h-2 bg-white/20 rounded-full overflow-hidden">
          <div
            className="h-full bg-white rounded-full transition-all duration-500"
            style={{ width: `${level.progress}%` }}
          />
        </div>
      </div>
    </div>
  );
}
```

### مكون الشارات

```typescript
// components/gamification/BadgeDisplay.tsx

'use client';

interface BadgeProps {
  badge: {
    id: string;
    name: string;
    description: string;
    image: string;
    rarity: 'common' | 'uncommon' | 'rare' | 'epic' | 'legendary';
    earnedAt?: string;
  };
  size?: 'sm' | 'md' | 'lg';
}

const rarityColors = {
  common: 'from-gray-400 to-gray-500',
  uncommon: 'from-green-400 to-green-500',
  rare: 'from-blue-400 to-blue-500',
  epic: 'from-purple-400 to-purple-500',
  legendary: 'from-yellow-400 to-orange-500',
};

const rarityLabels = {
  common: 'شائعة',
  uncommon: 'غير شائعة',
  rare: 'نادرة',
  epic: 'ملحمية',
  legendary: 'أسطورية',
};

export function BadgeDisplay({ badge, size = 'md' }: BadgeProps) {
  const sizeClasses = {
    sm: 'w-12 h-12',
    md: 'w-16 h-16',
    lg: 'w-24 h-24',
  };

  return (
    <div className="group relative">
      <div
        className={`${sizeClasses[size]} rounded-full bg-gradient-to-br ${rarityColors[badge.rarity]} p-1`}
      >
        <img
          src={badge.image}
          alt={badge.name}
          className="w-full h-full rounded-full object-cover"
        />
      </div>
      
      {/* Tooltip */}
      <div className="absolute bottom-full left-1/2 -translate-x-1/2 mb-2 opacity-0 group-hover:opacity-100 transition-opacity pointer-events-none">
        <div className="bg-gray-900 text-white text-xs rounded-lg p-2 whitespace-nowrap">
          <p className="font-semibold">{badge.name}</p>
          <p className="text-gray-400">{rarityLabels[badge.rarity]}</p>
          {badge.earnedAt && (
            <p className="text-gray-400 mt-1">
              تم获得: {new Date(badge.earnedAt).toLocaleDateString('ar')}
            </p>
          )}
        </div>
      </div>
    </div>
  );
}
```

### مكون لوحة المتصدرين

```typescript
// components/gamification/Leaderboard.tsx

'use client';

import { useState } from 'react';

interface LeaderboardEntry {
  rank: number;
  userId: string;
  name: string;
  avatar?: string;
  score: number;
}

interface LeaderboardProps {
  entries: LeaderboardEntry[];
  currentUserId?: string;
  showAvatar?: boolean;
}

export function Leaderboard({ entries, currentUserId, showAvatar = true }: LeaderboardProps) {
  const [period, setPeriod] = useState<'weekly' | 'monthly' | 'allTime'>('weekly');

  return (
    <div className="bg-white rounded-lg shadow-sm border border-gray-200">
      {/* العنوان */}
      <div className="p-4 border-b border-gray-200">
        <h3 className="text-lg font-semibold">لوحة المتصدرين</h3>
        
        {/* فلاتر الفترة */}
        <div className="flex gap-2 mt-2">
          {[
            { value: 'weekly', label: 'أسبوعي' },
            { value: 'monthly', label: 'شهري' },
            { value: 'allTime', label: 'كل الأوقات' },
          ].map((option) => (
            <button
              key={option.value}
              onClick={() => setPeriod(option.value as any)}
              className={`px-3 py-1 text-sm rounded-full ${
                period === option.value
                  ? 'bg-blue-500 text-white'
                  : 'bg-gray-100 text-gray-700 hover:bg-gray-200'
              }`}
            >
              {option.label}
            </button>
          ))}
        </div>
      </div>
      
      {/* القائمة */}
      <div className="divide-y divide-gray-100">
        {entries.map((entry) => (
          <div
            key={entry.userId}
            className={`flex items-center gap-4 p-4 ${
              entry.userId === currentUserId ? 'bg-blue-50' : ''
            }`}
          >
            {/* الترتيب */}
            <div className={`w-8 text-center font-bold ${
              entry.rank <= 3 ? 'text-yellow-500' : 'text-gray-500'
            }`}>
              {entry.rank <= 3 ? (
                <span className="text-xl">
                  {entry.rank === 1 ? '🥇' : entry.rank === 2 ? '🥈' : '🥉'}
                </span>
              ) : (
                entry.rank
              )}
            </div>
            
            {/* الصورة */}
            {showAvatar && (
              <img
                src={entry.avatar || '/default-avatar.png'}
                alt={entry.name}
                className="w-10 h-10 rounded-full"
              />
            )}
            
            {/* الاسم */}
            <div className="flex-1">
              <p className={`font-medium ${
                entry.userId === currentUserId ? 'text-blue-600' : ''
              }`}>
                {entry.name}
                {entry.userId === currentUserId && (
                  <span className="text-sm text-blue-500 mr-2">(أنت)</span>
                )}
              </p>
            </div>
            
            {/* النقاط */}
            <div className="text-left">
              <p className="font-bold text-lg">{entry.score.toLocaleString('ar')}</p>
              <p className="text-xs text-gray-500">نقطة</p>
            </div>
          </div>
        ))}
      </div>
    </div>
  );
}
```

---

## URLs API

```
# النقاط
GET /api/v1/gamification/points/
GET /api/v1/gamification/points/history/
POST /api/v1/gamification/points/earn/

# الشارات
GET /api/v1/gamification/badges/
GET /api/v1/gamification/badges/my/
POST /api/v1/gamification/badges/{id}/seen/

# الإنجازات
GET /api/v1/gamification/achievements/
GET /api/v1/gamification/achievements/my/
POST /api/v1/gamification/achievements/{id}/claim/

# التحديات
GET /api/v1/gamification/challenges/
GET /api/v1/gamification/challenges/active/
POST /api/v1/gamification/challenges/{id}/join/
GET /api/v1/gamification/challenges/{id}/progress/

# السلاسل
GET /api/v1/gamification/streak/
POST /api/v1/gamification/streak/check-in/

# لوحة المتصدرين
GET /api/v1/gamification/leaderboard/?period={period}&category={category}
GET /api/v1/gamification/leaderboard/my-rank/

# المستويات
GET /api/v1/gamification/levels/
GET /api/v1/gamification/levels/my/
```

---

## ملخص

> **نظام Gamification** يشمل: نقاط (15+ نشاط)، شارات (5 فئات نادرة)، إنجازات (تدريجية وسرية)، تحديات (يومية/أسبوعية/شهرية)، سلاسل يومية، لوحة متصدرين، ومستويات. يشمل React Components وAPI كامل.
