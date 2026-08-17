# مزودو الذكاء الاصطناعي

## Google Gemini

### الإعداد
```python
# providers/gemini.py
import google.generativeai as genai

class GeminiProvider(BaseProvider):
    name = "gemini"
    
    def __init__(self):
        genai.configure(api_key=settings.GEMINI_API_KEY)
        self.model = genai.GenerativeModel('gemini-2.0-flash')
    
    async def generate(self, prompt: str, **kwargs) -> AIResponse:
        import time
        start = time.time()
        
        try:
            response = self.model.generate_content(
                prompt,
                generation_config=genai.GenerationConfig(
                    temperature=kwargs.get('temperature', 0.7),
                    max_output_tokens=kwargs.get('max_tokens', 2000),
                )
            )
            
            latency = int((time.time() - start) * 1000)
            
            return AIResponse(
                content=response.text,
                model="gemini-2.0-flash",
                provider="gemini",
                prompt_tokens=response.usage_metadata.prompt_token_count,
                completion_tokens=response.usage_metadata.candidates_token_count,
                total_tokens=response.usage_metadata.total_token_count,
                latency_ms=latency,
                success=True
            )
        except Exception as e:
            return AIResponse(
                content="",
                model="gemini-2.0-flash",
                provider="gemini",
                prompt_tokens=0,
                completion_tokens=0,
                total_tokens=0,
                latency_ms=int((time.time() - start) * 1000),
                success=False,
                error=str(e)
            )
```

---

## OpenAI

### الإعداد
```python
# providers/openai.py
from openai import AsyncOpenAI

class OpenAIProvider(BaseProvider):
    name = "openai"
    
    def __init__(self):
        self.client = AsyncOpenAI(api_key=settings.OPENAI_API_KEY)
    
    async def generate(self, prompt: str, **kwargs) -> AIResponse:
        import time
        start = time.time()
        
        try:
            response = await self.client.chat.completions.create(
                model="gpt-4o",
                messages=[{"role": "user", "content": prompt}],
                temperature=kwargs.get('temperature', 0.7),
                max_tokens=kwargs.get('max_tokens', 2000)
            )
            
            latency = int((time.time() - start) * 1000)
            
            return AIResponse(
                content=response.choices[0].message.content,
                model="gpt-4o",
                provider="openai",
                prompt_tokens=response.usage.prompt_tokens,
                completion_tokens=response.usage.completion_tokens,
                total_tokens=response.usage.total_tokens,
                latency_ms=latency,
                success=True
            )
        except Exception as e:
            return AIResponse(
                content="",
                model="gpt-4o",
                provider="openai",
                prompt_tokens=0,
                completion_tokens=0,
                total_tokens=0,
                latency_ms=int((time.time() - start) * 1000),
                success=False,
                error=str(e)
            )
```

---

## Anthropic Claude

### الإعداد
```python
# providers/claude.py
import anthropic

class ClaudeProvider(BaseProvider):
    name = "claude"
    
    def __init__(self):
        self.client = anthropic.AsyncAnthropic(api_key=settings.ANTHROPIC_API_KEY)
    
    async def generate(self, prompt: str, **kwargs) -> AIResponse:
        import time
        start = time.time()
        
        try:
            response = await self.client.messages.create(
                model="claude-3-haiku-20240307",
                max_tokens=kwargs.get('max_tokens', 2000),
                messages=[{"role": "user", "content": prompt}]
            )
            
            latency = int((time.time() - start) * 1000)
            
            return AIResponse(
                content=response.content[0].text,
                model="claude-3-haiku",
                provider="claude",
                prompt_tokens=response.usage.input_tokens,
                completion_tokens=response.usage.output_tokens,
                total_tokens=response.usage.input_tokens + response.usage.output_tokens,
                latency_ms=latency,
                success=True
            )
        except Exception as e:
            return AIResponse(
                content="",
                model="claude-3-haiku",
                provider="claude",
                prompt_tokens=0,
                completion_tokens=0,
                total_tokens=0,
                latency_ms=int((time.time() - start) * 1000),
                success=False,
                error=str(e)
            )
```

---

## Ollama (Local)

### الإعداد
```python
# providers/ollama.py
import httpx

class OllamaProvider(BaseProvider):
    name = "ollama"
    
    def __init__(self):
        self.base_url = settings.OLLAMA_BASE_URL or "http://localhost:11434"
        self.model = settings.OLLAMA_MODEL or "llama3"
    
    async def generate(self, prompt: str, **kwargs) -> AIResponse:
        import time
        start = time.time()
        
        try:
            async with httpx.AsyncClient() as client:
                response = await client.post(
                    f"{self.base_url}/api/generate",
                    json={
                        "model": self.model,
                        "prompt": prompt,
                        "stream": False,
                        "options": {
                            "temperature": kwargs.get('temperature', 0.7),
                            "num_predict": kwargs.get('max_tokens', 2000)
                        }
                    }
                )
                response.raise_for_status()
                data = response.json()
            
            latency = int((time.time() - start) * 1000)
            
            return AIResponse(
                content=data['response'],
                model=self.model,
                provider="ollama",
                prompt_tokens=data.get('prompt_eval_count', 0),
                completion_tokens=data.get('eval_count', 0),
                total_tokens=data.get('prompt_eval_count', 0) + data.get('eval_count', 0),
                latency_ms=latency,
                success=True
            )
        except Exception as e:
            return AIResponse(
                content="",
                model=self.model,
                provider="ollama",
                prompt_tokens=0,
                completion_tokens=0,
                total_tokens=0,
                latency_ms=int((time.time() - start) * 1000),
                success=False,
                error=str(e)
            )
```

---

## المزود المخصص (Custom)

### الإعداد
```python
# providers/custom.py
import httpx

class CustomProvider(BaseProvider):
    name = "custom"
    
    def __init__(self, base_url: str, api_key: str, model: str):
        self.base_url = base_url
        self.api_key = api_key
        self.model = model
    
    async def generate(self, prompt: str, **kwargs) -> AIResponse:
        import time
        start = time.time()
        
        try:
            async with httpx.AsyncClient() as client:
                response = await client.post(
                    f"{self.base_url}/v1/chat/completions",
                    headers={"Authorization": f"Bearer {self.api_key}"},
                    json={
                        "model": self.model,
                        "messages": [{"role": "user", "content": prompt}],
                        "temperature": kwargs.get('temperature', 0.7),
                        "max_tokens": kwargs.get('max_tokens', 2000)
                    }
                )
                response.raise_for_status()
                data = response.json()
            
            latency = int((time.time() - start) * 1000)
            
            return AIResponse(
                content=data['choices'][0]['message']['content'],
                model=self.model,
                provider="custom",
                prompt_tokens=data.get('usage', {}).get('prompt_tokens', 0),
                completion_tokens=data.get('usage', {}).get('completion_tokens', 0),
                total_tokens=data.get('usage', {}).get('total_tokens', 0),
                latency_ms=latency,
                success=True
            )
        except Exception as e:
            return AIResponse(
                content="",
                model=self.model,
                provider="custom",
                prompt_tokens=0,
                completion_tokens=0,
                total_tokens=0,
                latency_ms=int((time.time() - start) * 1000),
                success=False,
                error=str(e)
            )
```
