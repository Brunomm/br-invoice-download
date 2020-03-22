# frozen_string_literal: true
# encoding: utf-8

require 'active_support/core_ext/string'
require 'active_support/core_ext/hash'
require 'savon'
require 'slim'

require 'br_invoice_download/version'
require 'br_invoice_download/nfe_distribuicao_dfe'


# Copyright (C) 2020 Bruno M. Mergen
#
# @author Bruno Mucelini Mergen <brunomergen@gmail.com>
#
#
module BrInvoiceDownload
	def self.root
		File.expand_path '../..', __FILE__
	end
end