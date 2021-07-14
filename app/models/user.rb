# frozen_string_literal: true

class User < ActiveRecord::Base
  extend Devise::Models
  # Include default devise modules. Others available are:
  # :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable, :confirmable,
         :recoverable, :rememberable, :validatable
  include DeviseTokenAuth::Concerns::User

  before_save :check_user_uid

  def check_user_uid()
    if self.uid.blank?
      self.uid = self.email
    end
  end
end
