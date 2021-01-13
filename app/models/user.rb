class User < ApplicationRecord
  attr_accessor :activation_token, :reset_token

  before_save :downcase_email
  before_create :create_activation_digest
  validates :name, presence: true, length: { maximum: 50 }
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i.freeze
  validates :email, presence: true, length: { maximum: 255 },
                    format: { with: VALID_EMAIL_REGEX },
                    uniqueness: { case_sensitive: false }
  has_secure_password
  validates :password, presence: true, length: { minimum: 6 }, allow_nil: true
  enum state: { inactive: 0, active: 1, locked: 2 }, _prefix: true
  has_many :posts

  # 渡された文字列のハッシュ値を返す
  def self.digest(string)
    BCrypt::Password.create(string, cost: BCrypt::Engine.cost)
  end

  # ランダムなトークンを返す
  def self.new_token
    SecureRandom.urlsafe_base64
  end

  # 渡されたトークンがダイジェストと一致したらtrueを返す
  def authenticated?(attribute, token)
    digest = send("#{attribute}_digest")
    return false if digest.nil?

    BCrypt::Password.new(digest).is_password?(token)
  end

  # アカウントを有効にする
  def activate
    update!(state: :active, activated_at: Time.zone.now)
  end

  # 有効化用のメールを送信する
  def send_activation_email
    UserMailer.account_activation(self).deliver_now
  end

  # パスワード再設定の属性を設定する
  def create_reset_digest
    self.reset_token = User.new_token
    update!(reset_digest: User.digest(reset_token), reset_sent_at: Time.zone.now)
  end

  # パスワード再設定のメールを送信する
  def send_password_reset_email
    UserMailer.password_reset(self).deliver_now
  end

  # パスワード再設定の期限が切れている場合はtrueを返す
  def password_reset_expired?
    reset_sent_at < 2.hours.ago
  end

  def display_state
    I18n.t("activerecord.enum.user.state.#{state}")
  end

  def self.list_json
    users = all.order(:id)
    only = [:id, :name, :email, :display_state]
    methods = [:display_state]
    users.as_json(methods: methods, only: only)
  end

  def display_role
    role = admin? ? :admin : :normal
    I18n.t("activerecord.display.user.role.#{role}")
  end

  def display_created_at
    created_at.present? ? created_at.strftime(DISPLAY_DATETIME) : ""
  end

  def display_activated_at
    activated_at.present? ? activated_at.strftime(DISPLAY_DATETIME) : ""
  end

  def display_locked_at
    locked_at.present? ? locked_at.strftime(DISPLAY_DATETIME) : ""
  end

  def to_display_json
    only = [:id, :name, :email, :display_state, :display_role,
            :display_created_at, :display_activated_at, :display_locked_at, :admin]
    methods = [:display_state, :display_role, :display_created_at,
               :display_activated_at, :display_locked_at]
    as_json(methods: methods, only: only)
  end

  def lock
    update!(state: :locked, locked_at: Time.zone.now)
  end

  def unlock
    update!(state: :active, locked_at: nil)
  end

  private

  # メールアドレスをすべて小文字にする
  def downcase_email
    self.email = email.downcase
  end

  # 有効化トークンとダイジェストを作成および代入する
  def create_activation_digest
    self.activation_token  = User.new_token
    self.activation_digest = User.digest(activation_token)
  end
end
