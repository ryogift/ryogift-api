require "rails_helper"
include ActiveJob::TestHelper

RSpec.describe User, type: :model do
  example "有効なファクトリを持つこと" do
    expect(FactoryBot.build(:user)).to be_valid
  end

  describe "validates" do
    example "名前が必須であること" do
      user = FactoryBot.build(:user, name: "     ")
      user.valid?
      expect(user.errors[:name]).to include I18n.t("errors.messages.blank")
    end

    example "名前が50文字以内であること" do
      user = FactoryBot.build(:user, name: "a" * 51)
      user.valid?
      expect(user.errors[:name]).to include I18n.t("errors.messages.too_long", count: 50)
    end

    example "メールアドレスが必須であること" do
      user = FactoryBot.build(:user, email: "     ")
      user.valid?
      expect(user.errors[:email]).to include I18n.t("errors.messages.blank")
    end

    example "メールアドレスが255文字以内であること" do
      user = FactoryBot.build(:user, email: "#{'a' * 244}@example.com")
      user.valid?
      expect(user.errors[:email]).to include I18n.t("errors.messages.too_long", count: 255)
    end

    example "メールアドレスが有効な形式であること" do
      valid_addresses = %w[user@example.com USER@foo.COM A_US-ER@foo.bar.org
                           first.last@foo.jp alice+bob@baz.cn]
      valid_addresses.each do |valid_address|
        expect(FactoryBot.build(:user, email: valid_address)).to be_valid
      end
    end

    example "メールアドレスの検証で無効なメールアドレスを拒否すること" do
      invalid_addresses = %w[user@example,com user_at_foo.org user.name@example.
                             foo@bar_baz.com foo@bar+baz.com]
      invalid_addresses.each do |invalid_address|
        user = FactoryBot.build(:user, email: invalid_address)
        user.valid?
        expect(user.errors[:email]).to include I18n.t("errors.messages.invalid")
      end
    end

    example "メールアドレスがユニークであること" do
      user = FactoryBot.create(:user)
      duplicate_user = user.dup
      duplicate_user.valid?
      expect(duplicate_user.errors[:email]).to include I18n.t("errors.messages.taken")
    end

    example "パスワードが必須(空白ではない)であること" do
      user = FactoryBot.build(:user, password: " " * 6, password_confirmation: " " * 6)
      user.valid?
      expect(user.errors[:password]).to include I18n.t("errors.messages.blank")
    end

    example "パスワードが6文字以上であること" do
      user = FactoryBot.build(:user, password: "a" * 5, password_confirmation: "a" * 5)
      user.valid?
      expect(user.errors[:password]).to include I18n.t("errors.messages.too_short", count: 6)
    end
  end

  describe "digest" do
    example "暗号化した文字列が返却されること" do
      expect(User.digest("test").length.positive?).to eq true
    end
  end

  describe "new_token" do
    example "トークンの文字列が返却されること" do
      expect(User.new_token.length.positive?).to eq true
    end
  end

  describe "authenticated?" do
    example "渡されたトークンがダイジェストと一致したらtrueを返すこと" do
      user = FactoryBot.build(:user)
      user.activate
      expect(user.authenticated?(:activation, user.activation_token)).to eq true
    end

    example "対象のダイジェストがnilの場合にfalseを返すこと" do
      user = FactoryBot.build(:user)
      expect(user.authenticated?(:activation, user.activation_digest)).to eq false
    end
  end

  describe "activate" do
    example "アカウントを有効にできること" do
      user = FactoryBot.create(:user)
      user.activate
      expect(user.state_active?).to eq true
    end

    example "アカウントを有効した日時が保存されていること" do
      user = FactoryBot.create(:user)
      user.activate
      expect(user.activated_at.present?).to eq true
    end
  end

  describe "send_activation_email" do
    example "有効化用のメールを送信すること" do
      user = FactoryBot.create(:user)
      ActiveJob::Base.queue_adapter = :test
      expect do
        perform_enqueued_jobs(only: ActionMailer::MailDeliveryJob) do
          user.send_activation_email
        end
      end.to change(ActionMailer::Base.deliveries, :count).by(1)
    end
  end

  describe "create_reset_digest" do
    example "パスワード再設定のダイジェストが保存されること" do
      user = FactoryBot.create(:user)
      user.create_reset_digest
      expect(user.reset_digest.length.positive?).to eq true
    end

    example "パスワード再設定をした日時が保存されていること" do
      user = FactoryBot.create(:user)
      user.create_reset_digest
      expect(user.reset_sent_at.present?).to eq true
    end
  end

  describe "send_password_reset_email" do
    example "パスワード再設定のメールを送信すること" do
      user = FactoryBot.create(:user)
      user.create_reset_digest
      ActiveJob::Base.queue_adapter = :test
      expect do
        perform_enqueued_jobs(only: ActionMailer::MailDeliveryJob) do
          user.send_password_reset_email
        end
      end.to change(ActionMailer::Base.deliveries, :count).by(1)
    end
  end

  describe "password_reset_expired?" do
    example "パスワード再設定の期限が切れている場合はtrueを返すこと" do
      user = FactoryBot.create(:user)
      user.reset_sent_at = 3.hours.ago
      user.save!
      expect(user.password_reset_expired?).to eq true
    end

    example "パスワード再設定の期限が切れていない場合はfalseを返すこと" do
      user = FactoryBot.create(:user)
      user.reset_sent_at = 1.hours.ago
      user.save!
      expect(user.password_reset_expired?).to eq false
    end
  end

  describe "display_state" do
    example "表示用の状態が取得できること" do
      user = FactoryBot.create(:user)
      expect(user.display_state).to eq I18n.t("activerecord.enum.user.state.#{user.state}")
    end
  end

  describe "list_json" do
    example "ユーザー 一覧(JSON形式)が取得できること" do
      user1 = FactoryBot.create(:user, email: "user1@example.com")
      user2 = FactoryBot.create(:user, email: "user2@example.com")
      result = User.list_json.map(&:deep_symbolize_keys)
      expect(result).to eq(
        [
          { id: user1.id, name: user1.name, email: user1.email, display_state: user1.display_state },
          { id: user2.id, name: user2.name, email: user2.email, display_state: user2.display_state }
        ]
      )
    end
  end

  describe "display_role" do
    example "管理者の表示用の権限名が取得できること" do
      user = FactoryBot.create(:user, admin: true)
      expect(user.display_role).to eq I18n.t("activerecord.display.user.role.admin")
    end

    example "一般の表示用の権限名が取得できること" do
      user = FactoryBot.create(:user, admin: false)
      expect(user.display_role).to eq I18n.t("activerecord.display.user.role.normal")
    end
  end

  describe "display_created_at" do
    example "表示用の作成日時が取得できること" do
      user = FactoryBot.create(:user)
      expect(user.display_created_at).to eq user.created_at.strftime(User::DISPLAY_DATETIME)
    end

    example "作成日時がnilの場合に空白が返されること" do
      user = FactoryBot.build(:user)
      expect(user.display_created_at).to eq ""
    end
  end

  describe "display_activated_at" do
    example "表示用のアクティブ日時が取得できること" do
      user = FactoryBot.create(:user)
      user.activate
      expect(user.display_activated_at).to eq user.activated_at.strftime(User::DISPLAY_DATETIME)
    end

    example "アクティブ日時がnilの場合に空白が返されること" do
      user = FactoryBot.create(:user, state: :inactive, activated_at: nil)
      expect(user.display_activated_at).to eq ""
    end
  end

  describe "display_locked_at" do
    example "表示用のロックした日時が取得できること" do
      user = FactoryBot.create(:user)
      user.lock
      expect(user.display_locked_at).to eq user.locked_at.strftime(User::DISPLAY_DATETIME)
    end

    example "ロックした日時がnilの場合に空白が返されること" do
      user = FactoryBot.create(:user)
      expect(user.display_locked_at).to eq ""
    end
  end

  describe "to_display_json" do
    example "ユーザーの表示用(JSON形式)が取得できること" do
      user = FactoryBot.create(:user)
      expect(user.to_display_json.deep_symbolize_keys).to eq(
        {
          id: user.id,
          name: user.name,
          email: user.email,
          display_state: user.display_state,
          display_role: user.display_role,
          display_created_at: user.display_created_at,
          display_activated_at: user.display_activated_at,
          display_locked_at: user.display_locked_at,
          admin: user.admin
        }
      )
    end
  end

  describe "lock" do
    example "アカウントをロックできること" do
      user = FactoryBot.create(:user)
      user.lock
      expect(user.state_locked?).to eq true
    end

    example "アカウントをロックした日時が保存されていること" do
      user = FactoryBot.create(:user)
      user.lock
      expect(user.locked_at.present?).to eq true
    end
  end

  describe "unlock" do
    example "アカウントをアンロックできること" do
      user = FactoryBot.create(:user)
      user.unlock
      expect(user.state_active?).to eq true
    end

    example "アカウントのアンロック時にロックした日時が削除されること" do
      user = FactoryBot.create(:user)
      user.unlock
      expect(user.locked_at.nil?).to eq true
    end
  end
end
