# frozen_string_literal: true

require_relative '../models/user'

class MessageSender
  attr_reader :bot, :message, :user

  RESPONSES = {
    greeting: 'Привет. Я бот, который помогает учить новые английские слова каждый день. ' \
    'Давай сперва определимся сколько слов в день (от 1 до 6) ты хочешь узнавать?',
    wrong_number: 'Я не умею учить больше чем 6 словам. Давай еще раз?',
    accept: 'Принято',
    remind: 'Кажется ты был слишком занят, и пропустил слово выше? Дай мне знать что у тебя все хорошо.',
    continue: 'Вижу что ты заметил слово! Продолжаем учиться дальше!'
  }.freeze

  def initialize(bot, message)
    @bot = bot
    @message = message
  end

  def send_answer
    if message.text == '/start'
      record_user
      greeting
    elsif number?(message.text) && correct_number?(message.text)
      accept
      user = User.find_by(telegram_id: message.from.id)
      user.update(words_per_day: message.text.to_i)
    elsif number?(message.text) && !correct_number?(message.text)
      wrong_number
    end
  end

  def number?(number)
    !number.match(/^[0-9]*$/).nil?
  end

  def correct_number?(number)
    (1..6).cover?(number.to_i)
  end

  def record_user
    User.find_or_create_by(
      telegram_id: message.from.id,
      name: message.from.first_name
    )
  end

  def greeting
    bot.api.send_message(
      chat_id: message.chat.id,
      text: RESPONSES[:greeting]
    )
  end

  def accept
    bot.api.send_message(
      chat_id: message.chat.id,
      text: RESPONSES[:accept]
    )
  end

  def wrong_number
    bot.api.send_message(
      chat_id: message.chat.id,
      text: RESPONSES[:wrong_number]
    )
  end
end
