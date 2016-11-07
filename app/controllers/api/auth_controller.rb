class Api::AuthController < ApplicationController
  skip_before_action :verify_authenticity_token
  before_action :authorize_user, only: [:giver_profile]
  respond_to :json
  Dotenv.load

  def giver_profile
    giver = Giver.find(1)
    charities = giver.followed_charities
    events = giver.events
    needs = giver.needs

    response_json = {giver: giver, charities: charities, events: events, needs: needs}.to_json

    render :json => JSON.pretty_generate(JSON.parse(response_json))
  end

  def test
    render :json => verify_access_token
  end

  private

  def authorize_user
    # begin
    #   decode_token(params[:token])
    # rescue JWT::VerificationError
    #   # Handle Signature verification raised error
        # return
    # rescue JWT::ExpiredSignature
    #   # Handle expired token, e.g. logout user or deny access
        # return
    # end
    token = generate_token(Giver.find_by(username: "samleiken"))
    p token
    p decode_token(token)
  end

  # Used to verify access token passed from FB OAuth server to iOS
  def verify_access_token
    # render status: :forbidden unless params[:access_token]
    #
    # access_token = params[:access_token]
    # response = HTTParty.get("https://graph.facebook.com/v2.8/#{fbid}?fields=first_name,last_name,email,picture&access_token#{access_token}")
    response = HTTParty.get("https://graph.facebook.com/v2.8/10210843918116483?fields=first_name,last_name,email,picture&access_token=EAAZA1sMymaZCABACsKWQzwU9ccEEZCxsAN6TJdCruUQN1WRCLxhwkBoymLNIZCcB6L2di4XtXcIPTtdRYIkTOlqqCHyVl78gBZBsCOZBiwy7xtM5frXPa8dSoTyaNAyLkw6egLeZCAGXbJEZAHpMxWM045IDZCIMBXFuoJGK7JZBRTagZDZD")

    if response.code == 200
      data = JSON.parse(response.body)
      # Login /register user
      user = Giver.from_mobile_omniauth(data)
      # return generate_token(user)
      return generate_token(user)
    end
    p response.code, "********************"
    JSON.pretty_generate(JSON.parse(response.body))
  end

  def generate_token(user)
    exp = Time.now.to_i + 7 * 3600
    payload = { user: user.username, exp: exp }
    JWT.encode payload, ENV['AUTH_SECRET'], 'HS256'
  end

  def decode_token(token)
    JWT.decode token, ENV['AUTH_SECRET'], true, { :algorithm => 'HS256' }
  end
end
