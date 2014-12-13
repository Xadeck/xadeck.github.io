module Jekyll
  # Page that reads its contents from the Gem `terminal.sass` file.
  class TerminalStylesheetPage <  Page
    def initialize(site, base, dir)
      @site = site
      @base = base
      @dir = dir
      @name = 'terminal.scss'

      self.process(@name)
      
      filepath = File.join(File.dirname(File.expand_path(__FILE__)), @name)
      self.content = File.read(filepath, merged_file_read_opts({}))
      self.data ||= {}
    end
  end

  # Generator that adds the stylesheet page to the generated site.
  class TerminalGenerator < Generator
    safe true

    def generate(site)      
      puts site.gems
      dir = 'css'
      site.pages << TerminalStylesheetPage.new(site, site.source, dir)
    end
  end

  class TerminalStylesheet < Liquid::Tag
    def initialize(tag_name, text, tokens)
      super
      @text = text
    end
        
    def render(context)
      '<link rel="stylesheet" href="#{}">'
    end
  end
  
  class Terminal < Liquid::Block

    def initialize(tag_name, text, tokens)
      super
      @text = text
    end

    def render(context)
      output = super(context)
      %{<div class="window">
          <nav class="control-window">
            <a href="#finder" class="close" data-rel="close">close</a>
            <a href="#" class="minimize">minimize</a>
            <a href="#" class="deactivate">deactivate</a>
          </nav>
          <h1 class="titleInside">Terminal</h1>
          <div class="container"><div class="terminal">#{promptize(output)}</div></div>
        </div>}
    end
    
    def promptize(content)
      content = content.strip
      gutters = content.lines.map { |line| gutter(line) }
      lines_of_code = content.lines.map { |line| line_of_code(line) }

      table = "<table><tr>"
      table += "<td class='gutter'><pre class='line-numbers'>#{gutters.join("\n")}</pre></td>"
      table += "<td class='code'><pre><code>#{lines_of_code.join("")}</code></pre></td>"
      table += "</tr></table>"
    end

    def gutter(line)
      gutter_value = line.start_with?(command_character) ? command_character : "&nbsp;"
      "<span class='line-number'>#{gutter_value}</span>"
    end

    def line_of_code(line)
      if line.start_with?(command_character)
        line_class = "command"
        line = line.sub(command_character,'').strip
      else
        line_class = "output"
      end
      "<span class='line #{line_class}'>#{line}</span>"
    end

    def command_character
      "$"
    end

  end
end

Liquid::Template.register_tag('terminal', Jekyll::Terminal)
Liquid::Template.register_tag('terminal_stylesheet', Jekyll::TerminalStylesheet)