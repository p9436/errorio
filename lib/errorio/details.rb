module Errorio
  # Some helpers
  class Details
    # Error details by code:
    #
    # errors.add :base, :invalid, Errorio.by_code(:E0001, user_id: 129)
    # => {
    #      code: :E0001,
    #      message: "Invitation from user with ID 1823 was expired"
    #      invited_by: 1823
    #    }
    def self.by_code(code, args = {})
      msg = I18n.t("errorio.messages.#{code}", args)
      {
        code: code,
        message: msg
      }.merge(args)
    end
  end
end
