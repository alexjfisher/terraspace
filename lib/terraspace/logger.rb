require 'logger'

module Terraspace
  class Logger < ::Logger
    def initialize(*args)
      super
      self.formatter = Formatter.new
      self.level = ENV['TS_LOG_LEVEL'] || :info # note: only respected when config.logger not set in config/app.rb
    end

    def format_message(severity, datetime, progname, msg)
      line = if @logdev.dev == $stdout || @logdev.dev == $stderr
        msg # super simple format if stdout
      else
        super # use the configured formatter
      end
      if line.force_encoding('UTF-8') =~ /\n$/
        out = line
      else
        out = "#{line}\n"
      end
      # out = line.force_encoding('UTF-8') =~ /\n$/ ? line : "#{line}\n"
      @@buffer << out
      out
    end

    # Used to allow terraform output to always go to stdout
    # Terraspace output goes to stderr by default
    # See: terraspace/shell.rb
    def stdout(msg, newline: true)
      out = newline ? "#{msg}\n" : msg
      @@buffer << out
      print out
    end

    def stdin_capture(text)
      @@buffer << "#{text}\n"
      @@stdin_capture = text
    end

    class << self
      @@stdin_capture = ''
      def stdin_capture
        @@stdin_capture
      end

      @@buffer = []
      def buffer
        @@buffer
      end

      def logs
        # force_encoding https://jch.github.io/posts/2013-03-05-ruby-incompatible-encoding.html
        @@buffer.map { |s| s.force_encoding('UTF-8') }.join('')
      end

      # for test framework
      def clear
        Terraspace::Command.reset_dispatch_command
        @@buffer = []
      end
    end
  end
end
