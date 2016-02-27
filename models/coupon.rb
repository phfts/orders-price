require_relative '../lib/active_record'

require 'time'

class Coupon
  extend ActiveRecord
  load_csv './files/coupons.csv', :id, :discount, :type, :expiration, :max_used

  validate(:id) { |id| id >= 0 }
  validate(:discount) { |discount| discount >= 0 }
  validate(:type) { |type| type == 'absolute' or type == 'percent' }
  validate(:expiration) { |expiration| expiration.is_a? Time }
  validate(:max_used) { |max_used| max_used >= 0 }

  def valid?
    @used_count ||= 0
    @used_count < max_used and Time.now < expiration
  end

  def relative_discount(total_price, mark_as_used: false)
    if valid? and total_price > 0
      @used_count += 1 if mark_as_used
      type == 'percent' ? discount : discount * 100.0 / total_price
    else
      0
    end
  end

end
