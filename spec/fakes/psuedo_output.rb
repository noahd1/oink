class PsuedoOutput < Array

  def puts(line)
    self << line
  end

end