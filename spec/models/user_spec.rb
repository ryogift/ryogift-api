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

    example "暗号化した文字列が返却されること" do
      expect(User.digest("test").length.positive?).to eq true
    end

    example "トークンの文字列が返却されること" do
      expect(User.new_token.length.positive?).to eq true
    end

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

    example "有効化用のメールを送信すること" do
      user = FactoryBot.create(:user)
      ActiveJob::Base.queue_adapter = :test
      expect do
        perform_enqueued_jobs(only: ActionMailer::MailDeliveryJob) do
          user.send_activation_email
        end
      end.to change(ActionMailer::Base.deliveries, :count).by(1)
    end

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

    example "パスワード再設定のメールを送信する" do
      user = FactoryBot.create(:user)
      user.create_reset_digest
      ActiveJob::Base.queue_adapter = :test
      expect do
        perform_enqueued_jobs(only: ActionMailer::MailDeliveryJob) do
          user.send_password_reset_email
        end
      end.to change(ActionMailer::Base.deliveries, :count).by(1)
    end

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
end
