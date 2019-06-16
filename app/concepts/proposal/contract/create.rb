module Proposal::Contract
  class Create < Reform::Form
    property :title
    property :abstract
    property :details
    property :pitch
    property :session_format_id
  end

end