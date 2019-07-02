Puppet::Functions.create_function(:gopass) do
  # @param key
  #   The key to look for
  #
  # @return hash
  #   The found password, body, and parsed data
  dispatch :gopass do
    param 'String', :key
    return_type 'Optional[Gopass::Secret]'
  end

  def gopass(key)
    # Avoid fuzzy search, see
    # https://github.com/gopasspw/gopass/issues/453#issuecomment-462477225
    keys = Puppet::Util::Execution.execute('gopass list --flat').split("\n")
    return nil unless keys.include? key

    lines = Puppet::Util::Execution.execute("gopass '#{key}'").split("\n")
    return nil if lines.length == 0

    password = lines[0]

    if lines.length > 1
      body = lines[1..-1].join("\n")
      begin
          data = YAML.load(body)
      rescue
          # leave data to nil
      end
    end

    {
      'password' => password,
      'body'     => body,
      'data'     => data,
    }
  end
end
