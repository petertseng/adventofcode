require 'prime'

target = Integer(!ARGV.empty? && ARGV.first.match?(/^\d+$/) ? ARGV.first : ARGF.read)

# sigma1 calculates the sum of the factors of n.
def sigma1(n)
  Prime.prime_division(n).map { |prime, power|
    (0..power).sum { |pow| prime ** pow }
  }.reduce(1, :*)
end

def gifts_delivered(house, elf_limit)
  gifts = 0
  (1..(house ** 0.5)).each { |candidate|
    next if house % candidate != 0
    factor1 = candidate
    factor2 = house / candidate
    gifts += factor1 if factor2 < elf_limit
    gifts += factor2 if factor1 < elf_limit && factor1 != factor2
  }
  gifts
end

def smallest_greater_factorial(target, valid_bound)
  factorial = 2
  n = 2
  until valid_bound[factorial]
    n += 1
    factorial *= n
  end
  [factorial, n]
end

def house_upper_bound(target, elf_limit: nil)
  if elf_limit
    valid_bound = ->(x) { gifts_delivered(x, elf_limit) >= target }
  else
    valid_bound = ->(x) { sigma1(x) >= target }
  end
  bound, n = smallest_greater_factorial(target, valid_bound)

  # Try to decrease each factor as far as it can go:
  n.downto(1) { |factor_to_decrease|
    bound_without = bound / factor_to_decrease
    (1...factor_to_decrease).each { |replacement|
      new_bound = bound_without * replacement
      if valid_bound[new_bound]
        bound = new_bound
        break
      end
    }
  }

  bound
end

def give_gifts(target, multiplier, elf_limit: nil)
  elf_value_needed = (target / multiplier.to_f).ceil

  # Find an upper bound on the house number.
  # This reduces the work we need to do in the loop.
  max_house = house_upper_bound(elf_value_needed, elf_limit: elf_limit)
  best = max_house
  gifts = Array.new(1 + max_house, 0)

  min_house = 1

  (1..max_house).each { |elf|
    if elf < min_house
      skipped = (min_house - 1) / elf
      start_house = (skipped + 1) * elf
    else
      skipped = 0
      start_house = elf
    end

    nums = (start_house..max_house).step(elf)
    if elf_limit
      next if skipped >= elf_limit
      nums = nums.take(elf_limit - skipped)
    end

    nums.each_with_index { |house, i|
      total_gifts = (gifts[house] += elf)
      if total_gifts >= elf_value_needed
        best = [best, house].min
        # If it's my first house, no later elf can undercut me.
        return best if i == 0 && skipped == 0
      end
    }
  }
  best
end

# It's absoutely untenable to iterate every house and find its factors.
# Just iterate the elves.

puts give_gifts(target, 10)
puts give_gifts(target, 11, elf_limit: 50)
