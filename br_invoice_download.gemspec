# -*- encoding: utf-8 -*-
require File.expand_path('../lib/br_invoice_download/version', __FILE__)

Gem::Specification.new do |gem|
	gem.name          = 'br-invoice-download'
	gem.version       = BrInvoiceDownload::Version::CURRENT
	gem.license       = 'MIT'
	gem.description   = %q{BrInvoiceDownload é uma gem para projetos Ruby on Rails que tem como objetivo fazer o download do xml das notas fiscais de produto emitidas no Brasil.}
	gem.summary       = %q{Download de Notas Fiscais Eletrônicas em Ruby}
	gem.authors       = ['Bruno M. Mergen']
	gem.email         = ['brunomergen@gmail.com']
	gem.homepage      = 'https://github.com/Brunomm/br-invoice-download'

	gem.files         = `git ls-files`.split("\n").reject{|fil|
		fil.include?('dev/') ||
		fil.include?('doc/')
	}
	gem.require_paths = ["lib"]
	gem.required_ruby_version = ['>= 2.1.0', '< 3.0.0']

	# gem.add_dependency "rake", '>= 10'
	gem.add_dependency 'activesupport', '>= 3'
	gem.add_dependency 'savon', '>= 2.11'
	# gem.add_dependency 'signer', '>= 1.4'
	gem.add_dependency 'slim', '>= 3.0'
	gem.add_dependency 'slim-rails', '>= 3.1'
	gem.add_dependency 'zlib', '>= 1.0'
	gem.add_dependency 'stringio', '>= 0.0.2'
end