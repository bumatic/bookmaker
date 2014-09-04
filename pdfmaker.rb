require 'rubygems'
require 'doc_raptor'

DocRaptor.api_key "***REMOVED***"

input_file = ARGV[0]
filename_split = input_file.split("\\").pop
filename = filename_split.split(".").shift.gsub(/ /, "")
working_dir_split = ARGV[0].split("\\")
working_dir = working_dir_split[0...-2].join("\\")
tmp_dir = "C:\\bookmaker_tmp"

html_file = "#{tmp_dir}\\#{filename}\\outputtmp.html"
pisbn = File.read("#{html_file}").scan(/Print ISBN:.*?<\/p>/).to_s.gsub(/-/,"").gsub(/Print ISBN: /,"").gsub(/<\/p>/,"").gsub(/\["/,"").gsub(/"\]/,"")

# pdf css to be added to the file that will be sent to docraptor
css_file = File.read("#{working_dir}\\done\\#{pisbn}\\layout\\pdf.css").to_s

# inserts the css into the head of the html
pdf_html = File.read("#{html_file}").gsub(/<\/head>/,"<style>#{css_file}</style></head>").to_s

# fix SSL connection error
`SET SSL_CERT_FILE=C:\\Ruby193\\lib\\ruby\\site_ruby\\1.9.1\\rubygems\\ssl_certs\\cacert.pem`

# sends file to docraptor for conversion
# currently running in test mode; remove test when css is finalized
`chdir #{tmp_dir}\\#{filename}`
File.open("#{pisbn}.pdf", "w+b") do |f|
  f.write DocRaptor.create(:document_content => pdf_html,
                           :name             => "#{pisbn}.pdf",
                           :document_type    => "pdf",
                           :strict			 => "none",
                           :test             => true)
end

# moves rendered pdf to archival dir
`move #{pisbn}.pdf #{working_dir}\\done\\#{pisbn}\\#{pisbn}_POD.pdf`