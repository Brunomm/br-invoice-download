# frozen_string_literal: true
# encoding: utf-8

require "zlib"
require "stringio"
require "base64"

module BrInvoiceDownload
	class NfeDistribuicaoDfe

		def initialize(opts={})
			opts.each do |key, value|
				instance_variable_set("@#{key}", value)
			end
		end

		attr_accessor :certificate_pkcs12_password
		attr_accessor :certificate_pkcs12_path
		attr_accessor :certificate_pkcs12_value
		attr_accessor :ibge_uf
		attr_accessor :cnpj
		attr_accessor :invoice_key

		def response
			@response
		end

		def request
			@response = client_wsdl.call(:nfe_dist_d_fe_interesse, xml: soap_xml)
			rescue Savon::SOAPFault => error
				return @response = {request_status: :soap_error,    request_message_error: error.message}
			rescue Savon::HTTPError => error
				return @response = {request_status: :http_error,    request_message_error: error.message}
			rescue Exception => error
				return @response = {request_status: :unknown_error, request_message_error: error.message}
		end

		def invoice_hash
			@invoice ||= handle_invoice
		end

		def invoice_xml
			@invoice_xml ||= handle_invoice_xml
		end

	private

		def handle_invoice_xml
			ret = response.try(:body).dig(:nfe_dist_d_fe_interesse_response, :nfe_dist_d_fe_interesse_result, :ret_dist_d_fe_int, :lote_dist_d_fe_int, :doc_zip)
			return unless ret

			Zlib::GzipReader.new(
		  	StringIO.new(
		  		Base64.decode64( ret )
		  	)
		  ).read
		end

		def handle_invoice
			Hash.from_xml invoice_xml
		end

		# Esse método serve para ser utilizado no Base de cada orgão emissor
		# onde em alguns casos é necessário colocar o xml em um CDATA
		# É esse método que é passado dentro do Body da equisição SOAP
		#
		def content_xml
			@content_xml ||= render_xml 'root/NfeDistribuicaoDfe'
		end

		# Tag XML que vai na requisição SOAP
		#
		# <b>Tipo de retorno: </b> _String_
		#
		def tag_xml
			'<?xml version="1.0" encoding="UTF-8"?>'
		end

		# XML que irá na requisição SOAP
		#
		# <b>Tipo de retorno: </b> _String XML_
		#
		def soap_xml
			@soap_xml ||= "#{tag_xml}#{render_xml('soap_env')}".html_safe
		end

		def client_wsdl_params
			{
				log:                   true,
				pretty_print_xml:      true,
				ssl_verify_mode:       :none,
				ssl_cert:              certificate,
				ssl_cert_key:          certificate_key,
				ssl_cert_key_password: certificate_pkcs12_password,
				wsdl: 'https://www1.nfe.fazenda.gov.br/NFeDistribuicaoDFe/NFeDistribuicaoDFe.asmx?wsdl',
				ssl_version: :TLSv1
			}
		end

		def url_xmlns
			'http://www.portalfiscal.inf.br/nfe/wsdl/NFeDistribuicaoDFe'
		end

		# Cliente WSDL utilizado para fazer a requisição.
		# Utilizando a gem savon.
		# Veja mais detalhes em http://savonrb.com/version2/client.html
		def client_wsdl
			@client_wsdl ||= Savon.client( client_wsdl_params )
		end

		# Caso não tenha o certificate_pkcs12 salvo em arquivo, pode setar a string do certificate_pkcs12 direto pelo atributo certificate_pkcs12_value
		# Caso tenha o certificate_pkcs12 em arquivo, basta setar o atributo certificate_pkcs12_path e deixar o atributo certificate_pkcs12_value em branco
		def certificate_pkcs12_value
			@certificate_pkcs12_value ||= File.read(certificate_pkcs12_path)
		end

		def certificate_pkcs12
			return @certificate_pkcs12 if @certificate_pkcs12
			@certificate_pkcs12 = nil

			# É utilizado uma Thread e limpado os errors do OpenSSL para evitar perda de
			# conexão com o banco de dados PostgreSQL.
			# Veja: http://stackoverflow.com/questions/33112155/pgconnectionbad-pqconsumeinput-ssl-error-key-values-mismatch/36283315#36283315
			# Veja: https://github.com/tedconf/front_end_builds/pull/66
			Thread.new do
				@certificate_pkcs12 = OpenSSL::PKCS12.new(certificate_pkcs12_value, certificate_pkcs12_password)
				OpenSSL.errors.clear
			end.join
			OpenSSL.errors.clear

			@certificate_pkcs12
		rescue
		end

		def certificate_pkcs12=(value)
			@certificate_pkcs12 = value
		end

		def certificate=(value)
			@certificate = value
		end

		def certificate
			@certificate ||= (certificate_pkcs12 && certificate_pkcs12.certificate)
		end

		def certificate_key
			@certificate_key ||= (certificate_pkcs12 && certificate_pkcs12.key)
		end

		def certificate_key=(value)
			@certificate_key = value
		end

		# Utilização
		# `render_xml('file_name', {dir_path: '/my/custom/dir', context: Object}`
		#
		# <b>Tipo de retorno: <b> _String_ (XML)
		#
		def render_xml file_name, opts={}
			opts = {
				dir_path: nil,
				context:  self,
			}.merge(opts)

			# Inicializa a variavel xml com nil para comparar se oa rquivo foi de fato encontrado.
			xml = nil
			get_xml_dirs(opts[:dir_path]).each do |dir|
				if xml = find_xml(file_name, dir, opts[:context], opts)
					break # Stop loop
				end
			end

			# Lança uma excessão se não for encontrado o xml
			# Deve verificar se é nil pois o arquivo xml pode estar vazio
			if xml.nil?
				raise "Arquivo #{file_name}.xml.slim não encontrado nos diretórios #{get_xml_dirs(default_options[:dir_path])}"
			end
			xml
		end

		def find_xml(file_name, dir, context=nil, options={})
			if File.exists?("#{dir}/#{file_name}.xml.slim")
				Slim::Template.new("#{dir}/#{file_name}.xml.slim").render(context, options).html_safe
			end
		end

		def get_xml_dirs(custom_dir_path=nil)
			[custom_dir_path, "#{BrInvoiceDownload.root}/lib/br_invoice_download/xml"].flatten.select(&:present?)
		end
	end
end