module Rockauth
  class ProviderUserInformation < Struct.new(:access_token, :access_token_secret)
    def self.for_provider provider, access_token, access_token_secret
      klass = "#{self}::#{provider.to_s.classify}".constantize
      klass.new(access_token, access_token_secret)
    end

    def valid?
      user_id.present?
    end

    class Facebook < ProviderUserInformation
      def user_id
        user.try(:identifier)
      end

      def picture_url
        user.picture :large
      end

      def user
        @user ||= FbGraph::User.me(access_token).fetch
      end
    end

    class Twitter < ProviderUserInformation
      def user_id
        user.try(:id)
      end

      def user
        @user ||= twitter_client.verify_credentials rescue nil
      end

      private

      def twitter_client
        @twitter_client ||= ::Twitter::REST::Client.new do |config|
          config.consumer_key        = Configuration.twitter[:consumer_key]
          config.consumer_secret     = Configuration.twitter[:consumer_secret]
          config.access_token        = access_token
          config.access_token_secret = access_token_secret
        end
      end

    end


    class GooglePlus < ProviderUserInformation
      def user_id
        user.try(:id)
      end

      def picture_url
        (user.try(:image) || {})[:url]
      end

      def user
        @user ||= GooglePlus::Person.get('me', key: access_token) rescue nil
      end
    end


    class Instagram < ProviderUserInformation
      def user_id
        user.try(:id)
      end

      def picture_url
        user.try(:profile_picture)
      end

      def user
        @user ||= Instagram.client(access_token: access_token).user rescue nil
      end
    end

  end
end
