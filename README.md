
# **br-invoice-download**
Gem para fazer o download de notas fiscais através da chave de acesso

**Introdução**

Através do serviço **NFeDistribuicaoDFe** é possível obter o XML da nota fiscal com suas informações.
Com base na documentação da [NT 2014.002 v1.02](/doc/NT2014.002_v1.02_WsNFeDistribuicaoDFe.pdf) foi criado apenas o serviço para a disponibilização do xml da nota fiscal, onde somente o destinatário, transportador e terceiros (identificados na tag `autXML`) podem usar este serviço.

## Instalação
**Manualmente**

    gem install br-invoice-download

**Gemfile**

     gem 'br-invoice-download'

## Utilização

```ruby
@engine = BrInvoiceDownload::NfeDistribuicaoDfe.new({
  certificate_pkcs12_password: 'CERTIFITACE_PASSWORD',
  certificate_pkcs12_path:     '/path/for/certificate-A1.pfx',
  cnpj:                        '12345678901234',
  invoice_key:                 '42200231775690400191560010004277701695237709',
  ibge_uf:                     42 # vide https://www.ibge.gov.br/explica/codigos-dos-municipios.php
})

@engine.request

@engine.invoice_xml
# => "<nfeProc versao=\"4.00\" xmlns=\"http://www.portalfiscal.inf.br" ...."

@engine.invoice_hash
# => {"nfeProc"=>{"versao"=>"4.00", "xmlns"=>"http://www.portalfiscal.inf.br/nfe", ...}

```

## Contribuições

Seja um contribuidor. Você pode contribuir de várias formas:

* Desenvolver as outras funcionalidades disponibilizadas pelo serviço **NFeDistribuicaoDFe**.
* Refatorando código.
* Fornecendo Feedback construtivo (*Sempre bem vindo!*).


## Licença

- MIT
- Copyleft 2020 Bruno Mucelini Mergen
