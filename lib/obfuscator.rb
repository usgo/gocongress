module Obfuscator
  def obfuscation_factor
    Kernel.rand((1..10)).to_i
  end
end
