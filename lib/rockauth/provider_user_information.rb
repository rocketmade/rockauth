module Rockauth
  class ProviderUserInformation < Struct.new(:access_token, :access_token_secret)
    def self.for_provider provider, access_token, access_token_secret
      klass = "#{self}::#{provider.to_s.camelize}".constantize
      klass.new(access_token, access_token_secret)
    end

    def valid?
      user_id.present?
    end

    def user
      @user ||= begin
                  get_user
                rescue StandardError => e
                  Rails.logger.error "[Rockauth] Could not authenticate social user: #{e}"
                  nil
                end
    end

    def get_user
    end

    class Facebook < ProviderUserInformation
      def user_id
        user.try(:identifier)
      end

      def picture_url
        user.picture :large
      end

      def get_user
        FbGraph2::User.me(access_token).fetch
      end
    end

    class Twitter < ProviderUserInformation
      def user_id
        user.try(:id)
      end

      def picture_url
        user.profile_image_url_https(:bigger).to_s
      end

      def get_user
        twitter_client.verify_credentials(skip_status: 1)
      end

      private

      def twitter_client
        @twitter_client ||= ::Twitter::REST::Client.new do |config|
          config.consumer_key        = Configuration.providers.twitter[:consumer_key]
          config.consumer_secret     = Configuration.providers.twitter[:consumer_secret]
          config.access_token        = access_token
          config.access_token_secret = access_token_secret
        end
      end
    end

    class GooglePlus < ProviderUserInformation
      def user_id
        user[:sub]
      end

      # TODO: Implement a way of retreiving profile picture from google.
      def picture_url
        {}
      end

      def get_user
        content = nil

        uri = URI.parse('https://www.googleapis.com/oauth2/v3/tokeninfo')
        uri.query = { id_token: access_token }.to_param

        open(uri) do |f|
          content = f.read
        end

        JSON.load(content).with_indifferent_access
      end
    end


    class Instagram < ProviderUserInformation
      def user_id
        user.try(:id)
      end

      def picture_url
        user.try(:profile_picture)
      end

      def get_user
        ::Instagram.client(access_token: access_token).user
      end
    end

  end
end
