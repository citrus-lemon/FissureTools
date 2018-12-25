require_relative 'binding'

module ProxyManager
  module SystemConfig
    module_function
    DefaultProxiesExceptionsList = []
    def set_sysconf(*a, **h)
      mode = (a[0] || h[:mode]).to_s.to_sym
      mode = :auto if h[:pac]
      if h[:socks]
        mode = :global
        h[:socks] =~ /^(?:socks[(?:4a?)5]:\/\/)?(.*?):(\d{1,5})\/?/
        h[:socksproxy] = $1
        h[:port] = $2.to_i
      end
      unless [:auto, :global, :off].include? mode
        raise ArgumentError, "mode must be one of :auto, :global, :off"
      end
      proxiesExceptionsList = case h[:exceptions]
      when String
        h[:exceptions].split(',').map(&:strip)
      when Array
        h[:exceptions]
      else
        DefaultProxiesExceptionsList
      end
      proxies = {
        NetworkProxiesHTTPEnable => false,
        NetworkProxiesHTTPSEnable => false,
        NetworkProxiesSOCKSEnable => false,
        NetworkProxiesExceptionsList => []
      }
      case mode
      when :auto
        proxies[NetworkProxiesProxyAutoConfigURLString] = h[:pac] || a[1]
        proxies[NetworkProxiesProxyAutoConfigEnable] = true
        proxies[NetworkProxiesExceptionsList] = proxiesExceptionsList
      when :global
        proxies[NetworkProxiesSOCKSProxy] = h[:socksproxy] || '127.0.0.1'
        proxies[NetworkProxiesSOCKSPort] = (h[:port] || a[1]).to_i
        proxies[NetworkProxiesSOCKSEnable] = true
        proxies[NetworkProxiesExceptionsList] = proxiesExceptionsList
      when :off
      end
      all_config = get_proxy().to_a
      all_config.select { |interface|
        %w(AirPort Wi-Fi Ethernet)
          .include? interface[1]['Interface']['Hardware'] }.map do |interface|
        change_config("/#{PrefNetworkServices}/#{interface[0]}/#{EntNetProxies}", proxies)    
      end
      apply_change()
    end
  end
end
