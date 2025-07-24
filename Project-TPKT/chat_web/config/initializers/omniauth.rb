Rails.application.config.middleware.use OmniAuth::Builder do
  provider :openid_connect, {
    name: :keycloak,
    scope: [:openid, :email, :profile],
    response_type: :code,
    client_options: {
      identifier: 'rails-app',
      secret: ENV['KEYCLOAK_SECRET'],
      redirect_uri: 'http://localhost:3000/auth/keycloak/callback',
      host: 'localhost',
      port: 8080,
      scheme: 'http',
      discovery: true,
      issuer: "http://localhost:8080/realms/#{ENV['KEYCLOAK_REALM']}"
    }
  }
end