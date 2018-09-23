require 'liqpay'

Liqpay::Liqpay.class_eval do
  def cnb_form_data(params)
    params = normalize_and_check(params, {}, :version, :amount, :currency, :description)
    language = params[:language] || 'ru'

    data, signature = data_and_signature(params)

    OpenStruct.new(
      url: client.endpoint('3/checkout'),
      data: data,
      signature: signature,
      language: language
    )
  end
end

module OffsitePayments
  module Integrations
    module LiqpayV3
      mattr_accessor :service_url
      self.service_url = 'https://www.liqpay.com/api/3/checkout'

      def self.notification(post, options = {})
        Notification.new(post, options)
      end

      def self.return(query_string, options = {})
        Return.new(query_string)
      end

      class Helper < OffsitePayments::Helper
        def initialize(order, account, options = {})
          @secret = options.delete(:credential2)
          super

          add_field 'version', '3'
        end

        mapping :account, 'merchant_id'
        mapping :amount, 'amount'
        mapping :currency, 'currency'
        mapping :description, 'description'
        mapping :customer, email: 'email'
        mapping :order, 'order_id'
        mapping :action, 'action'
        mapping :notify_url, 'server_url'
        mapping :return_url, 'result_url'

        def form_fields
          form_data = liqpay.cnb_form_data(
            version: @fields['version'],
            amount: @fields['amount'],
            currency: @fields['currency']&.upcase,
            description: @fields['description'],
            email: @fields['email'],
            sandbox: OffsitePayments.mode == :test ? '1' : '0',
            action: @fields['action'],
            order_id: @fields['order_id']&.to_s,
            server_url: @fields['server_url'],
            result_url: @fields['result_url'],
          )

          {
            'data' => form_data.data,
            'signature' => form_data.signature
          }
        end

        private

        def liqpay
          @liqpay ||= ::Liqpay.new(public_key: @fields['merchant_id'], private_key: @secret)
        end
      end

      class Notification < OffsitePayments::Notification
        include ActiveUtils::PostsData

        def initialize(post, options = {})
          raise ArgumentError if post.blank?
          super

          post_params = CGI.parse(post).transform_values(&:first)
          @params.merge!(liqpay.decode_data(post_params['data']))
        end

        def self.recognizes?(params)
          params.key?('signature') && params.key?('data')
        end

        def complete?
          params['status'].in? ['success', 'sandbox']
        end

        def account
          params['public_key']
        end

        def amount
          params['amount']
        end

        def item_id
          params['order_id']
        end

        def transaction_id
          params['transaction_id']
        end

        def currency
          params['currency']
        end

        def method
          params['paytype']
        end

        def security_key
          params['signature']
        end

        def acknowledge(_authcode = nil)
          liqpay.match?(params['data'], params['signature'])
        end

        private

        def liqpay
          @liqpay ||= ::Liqpay.new(public_key: account, private_key: @options[:credential2])
        end
      end

      class Return < OffsitePayments::Return
      end
    end
  end
end
