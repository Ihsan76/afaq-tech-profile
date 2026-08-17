# الاختبارات

## استراتيجية الاختبار

### أنواع الاختبارات

| النوع | الأداة | النسبة |
|-------|--------|--------|
| **Unit Tests** | pytest / Vitest | 70% |
| **Integration Tests** | pytest | 20% |
| **E2E Tests** | Cypress / Playwright | 10% |

---

## اختبارات Backend (pytest)

### الإعداد
```python
# pytest.ini
[pytest]
DJANGO_SETTINGS_MODULE = config.settings.testing
python_files = tests.py test_*.py *_tests.py
addopts = -v --cov=.
```

### مثال: اختبار نموذج المستخدم
```python
# users/tests/test_models.py
import pytest
from users.models import User

@pytest.mark.django_db
class TestUserModel:
    
    def test_create_user(self):
        user = User.objects.create_user(
            email='test@example.com',
            password='testpass123',
            name_ar='مستخدم تجريبي'
        )
        assert user.email == 'test@example.com'
        assert user.role == 'student'
        assert user.is_active
    
    def test_create_superuser(self):
        admin = User.objects.create_superuser(
            email='admin@example.com',
            password='adminpass123',
            name_ar='مدير'
        )
        assert admin.is_staff
        assert admin.is_superuser
```

### مثال: اختبار API
```python
# users/tests/test_api.py
import pytest
from rest_framework.test import APIClient
from users.models import User

@pytest.mark.django_db
class TestAuthAPI:
    
    def setup_method(self):
        self.client = APIClient()
    
    def test_register(self):
        response = self.client.post('/api/v1/auth/register/', {
            'email': 'new@example.com',
            'password': 'securepass123',
            'password_confirm': 'securepass123',
            'name_ar': 'مستخدم جديد',
            'role': 'teacher'
        })
        assert response.status_code == 201
        assert 'access' in response.data
    
    def test_login(self):
        User.objects.create_user(
            email='test@example.com',
            password='testpass123'
        )
        response = self.client.post('/api/v1/auth/login/', {
            'email': 'test@example.com',
            'password': 'testpass123'
        })
        assert response.status_code == 200
        assert 'access' in response.data
```

### مثال: اختبار AI
```python
# ai/tests/test_service.py
import pytest
from ai.services import AIService
from unittest.mock import AsyncMock, patch

@pytest.mark.asyncio
class TestAIService:
    
    @patch('ai.providers.gemini.GeminiProvider.generate')
    async def test_generate_lesson_plan(self, mock_generate):
        mock_generate.return_value = AsyncMock(
            success=True,
            content='{"title": "test"}',
            provider='gemini',
            total_tokens=100
        )
        
        service = AIService()
        response = await service.generate(
            user=None,
            feature='lesson_plan',
            prompt='test prompt'
        )
        
        assert response.success
        assert response.provider == 'gemini'
```

---

## اختبارات Frontend (Vitest)

### الإعداد
```typescript
// vitest.config.ts
import { defineConfig } from 'vitest/config';

export default defineConfig({
  test: {
    environment: 'jsdom',
    globals: true,
  },
});
```

### مثال
```typescript
// components/__tests__/Button.test.tsx
import { render, screen, fireEvent } from '@testing-library/react';
import { Button } from '../Button';

describe('Button', () => {
  it('renders correctly', () => {
    render(<Button>Click me</Button>);
    expect(screen.getByText('Click me')).toBeInTheDocument();
  });
  
  it('calls onClick when clicked', () => {
    const handleClick = vi.fn();
    render(<Button onClick={handleClick}>Click me</Button>);
    fireEvent.click(screen.getByText('Click me'));
    expect(handleClick).toHaveBeenCalled();
  });
});
```

---

## اختبارات E2E (Playwright)

### مثال
```typescript
// tests/auth.spec.ts
import { test, expect } from '@playwright/test';

test('user can login', async ({ page }) => {
  await page.goto('/login');
  await page.fill('input[name="email"]', 'test@example.com');
  await page.fill('input[name="password"]', 'password123');
  await page.click('button[type="submit"]');
  
  await expect(page).toHaveURL('/dashboard');
});
```

---

## CI/CD

```yaml
# .github/workflows/test.yml
name: Tests
on: [push, pull_request]

jobs:
  test-backend:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Set up Python
        uses: actions/setup-python@v5
        with:
          python-version: '3.12'
      - name: Install dependencies
        run: pip install -r requirements/testing.txt
      - name: Run tests
        run: pytest --cov=. --cov-report=xml
      - name: Upload coverage
        uses: codecov/codecov-action@v3

  test-frontend:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Setup Node
        uses: actions/setup-node@v4
        with:
          node-version: '20'
      - name: Install dependencies
        run: npm ci
      - name: Run tests
        run: npm test
```

---

## التغطية

| المكون | الهدف |
|--------|-------|
| Backend | 80%+ |
| Frontend | 70%+ |
| E2E | السيناريوهات الأساسية |
