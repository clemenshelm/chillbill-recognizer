# frozen_string_literal: true
require_relative '../detectors/invoice_number_detector'
require_relative '../models/invoice_number_term'
require_relative '../models/dimensionable'

class InvoiceNumberCalculation
  def invoice_number
    return nil if InvoiceNumberTerm.empty?
    label = InvoiceNumberLabelTerm.first
    invoice_number = if label
                       InvoiceNumberTerm.right_after(label) ||
                         InvoiceNumberTerm.right_below(label)
                     else
                       InvoiceNumberTerm.where(needs_label: false).first
                     end
    invoice_number.to_s if invoice_number
  end
end
