# frozen_string_literal: true

require_relative '../models/word'
require_relative '../models/user'
require_relative '../config/connection'
require_relative 'postman/send_reminder'
require_relative 'postman/send_word'
require_relative 'services/new_word_for_user'

class Teacher
  def self.send_word
    User
      .learning
      .reject(&:done_for_today?)
      .each do |user|
        word = NewWordForUser.new(user).call
        Postman::SendWord.send(word, user)
        user.wait!
      end
  end

  def self.remind
    User
      .waiting
      .filter(&:need_to_send_reminder?)
      .each do |user|
        Postman::SendReminder.send(user)
      end
  end
end
