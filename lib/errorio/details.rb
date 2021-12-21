module Errorio
  # Some helpers
  class Details
    # Interpolate error message from i18n
    #
    # @param [Symbol] code
    # @param [Hash] args
    #
    # @return [String]
    #
    def self.t_msg(code, args = {})
      I18n.t("errorio.messages.#{code}", **args)
    end

    # Error details by code:
    #
    # errors.add :base, :invalid, Errorio.by_code(:E0001, user_id: 129)
    # => {
    #      code: :E0001,
    #      message: "Invitation from user with ID 1823 was expired"
    #      invited_by: 1823
    #    }
    #
    # @param [Symbol] code
    # @param [Hash] args
    #
    # @return [Hash]
    def self.by_code(code, args = {})
      msg = t_msg(code, args)
      {
        code: code,
        message: msg
      }.merge(args)
    end
  end
end
