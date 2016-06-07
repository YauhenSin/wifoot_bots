Rails.application.routes.draw do
  telegram_webhooks TelegramWebhooksController

  #telegram_webhooks Telegram.bots[:wifoot] => TelegramWebhooksController
  #telegram_webhooks Telegram.bots[:wifoot_staging] => TelegramWebhooksController
  #telegram_webhooks Telegram.bots[:wifoot] => TelegramWebhooksReiroController

  #mount Messenger::Bot::Space => "/webhook"
  mount Facebook::Messenger::Server, at: 'bot'

  get "/message" => "telegram_bot#message", :format => "xml"

end
#Facebook::Messenger::Subscriptions.subscribe