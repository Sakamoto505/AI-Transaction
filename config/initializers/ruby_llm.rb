# config/initializers/ruby_llm.rb
require "ruby_llm"

RubyLLM.configure do |config|
  config.openai_api_base = "http://localhost:11434/v1" # Ollama OpenAI-совместимый API
  config.openai_api_key = "dummy" # Ollama не требует ключа
  config.default_model = "mistral"
end