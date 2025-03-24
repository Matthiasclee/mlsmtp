class OpenSSL::ASN1::ObjectId
  @@original_register_method = self.method("register")

  def self.register(*args)
    begin
      @@original_register_method.call(*args)
    rescue OpenSSL::ASN1::ASN1Error
      return false
    rescue => e
      raise e
    end
  end
end
