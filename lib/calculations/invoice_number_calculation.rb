# frozen_string_literal: true
require_relative '../detectors/invoice_number_detector'
require_relative '../models/invoice_number_term'
require_relative '../models/dimensionable'

class InvoiceNumberCalculation
  def invoice_number
    return nil if InvoiceNumberTerm.empty?
    if InvoiceNumberLabelTerm.any?
      invoice_number = InvoiceNumberTerm.right_after(InvoiceNumberLabelTerm.first) || InvoiceNumberTerm.right_below(InvoiceNumberLabelTerm.first)
    else
      invoice_number = InvoiceNumberTerm.where(needs_label: true).first
    end
    if invoice_number
      invoice_number.to_s
    else
      nil
    end
  end
end
