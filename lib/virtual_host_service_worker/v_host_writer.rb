module VirtualHostServiceWorker

  class VHostWriter

    def self.setup_v_host(payload)
      raise NotImplementedError.new
    end

    ##
    # exectue system commands and raises an execption if this fails.
    # This method should be used to trigger an webserver reload.
    def self.execute_command(command, custom_message = nil, expected_return = 0)
      stdout = `#{command} 2>&1`

      if $?.exitstatus != expected_return
        raise "Exception on executing command: #{command}\n Custom Message: #{custom_message}\n Command-Result: #{stdout}"
      end
      return true
    end

  end

end
