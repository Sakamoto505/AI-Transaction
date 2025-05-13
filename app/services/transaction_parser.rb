# app/services/transaction_parser.rb
require "ollama-ai"

class TransactionParser
  PROMPT = <<~TEXT
    Проанализируй текст траты и верни **строго JSON** вида:
    { "category": "категория", "amount": сумма в рублях как целое число }

    **Инструкции**:
    1. Всегда возвращай только JSON, без дополнительного текста.
    2. Сумма должна быть целым числом (без дробей).
    3. Категория должна быть из списка ниже.
    4. Если сумма не указана или текст непонятен, верни { "category": "Другое", "amount": 0 }.

    Примеры:
    - "Купил молоко за 150 рублей" → { "category": "Продукты", "amount": 150 }
    - "Проезд в метро 50 рублей" → { "category": "Транспорт", "amount": 50 }
    - "Неизвестная трата 200 рублей" → { "category": "Другое", "amount": 200 }

    Возможные категории: Продукты, Транспорт, Кафе, Развлечения, Коммуналка, Подписки, Связь, Дом, Одежда, Красота, Спорт, Здоровье, Подарки, Образование, Работа, Дети, Домашние животные, Путешествия, Финансы, Другое.

    Трата: "%{text}"
  TEXT

  def self.call(text:)
    return { "category" => "Другое", "amount" => 0 } if text.blank?

    prompt = PROMPT % { text: text.strip }
    client = Ollama.new(credentials: { address: "http://localhost:11434" })
    result = client.generate({ model: "mistral", prompt: prompt, options: { temperature: 0.3 } })

    full_response = result.map { |r| r["response"] }.join.strip
    parsed = begin
               JSON.parse(full_response)
             rescue JSON::ParserError => e
               Rails.logger.error("JSON parse error: #{e.message}, Raw: #{full_response}")
               { "category" => "Другое", "amount" => 0 }
             end
    parsed
  rescue StandardError => e
    { "category" => "Другое", "amount" => 0 }
  end
end