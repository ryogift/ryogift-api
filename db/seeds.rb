email = ENV.fetch("ADMIN_EMAIL")
password_digest = User.digest(ENV.fetch("ADMIN_PASSWORD"))
User.create(name: "管理者", email: email, password_digest: password_digest,
            activated: true, admin: true, state: :active)
