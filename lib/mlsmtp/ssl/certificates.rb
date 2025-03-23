module SMTPServer
  module SSL
    class Certificate
      @@certificates = {}

      def initialize(name="cert", certificate: nil, key:)
        @name = name

        @key = key.is_a?(String) ? OpenSSL::PKey::RSA.new(key) : key

        if certificate
          @certificate = certificate.is_a?(String) ? OpenSSL::X509::Certificate.new(certificate) : certificate

          @context = OpenSSL::SSL::SSLContext.new
          @context.cert = @certificate
          @context.key = @key
        end

        @@certificates[@name] = self
      end

      def destroy
        @@certificates.delete(@name)
      end

      def self.[](k)
        @@certificates[k]
      end

      def self.[]=(k, v)
        @@certificates[k] = v
      end

      def self.all
        @@certificates
      end

      attr_accessor :certificate, :key, :context
      attr_reader :name

      Config.active["certificates"].each do |name, info|
        cert = info["cert_path"] ? File.read(info["cert_path"]) : nil
        key = File.read(info["key_path"])

        new(name, certificate: cert, key: key)
      end
    end
  end
end
