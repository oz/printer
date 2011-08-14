# encoding: utf-8

class Home < Cramp::Action
  def start
    p Job.first
    render haml(:index)
    finish
  end

  private

  def haml(template)
    # Template paths
    tpl_path    = Printer::Application.root + "/app/views/#{ template }.haml"
    layout_path = Printer::Application.root + "/app/views/layout.haml"

    # Read files
    tpl_data    = File.read(tpl_path)
    layout_data = File.read(layout_path) if File.exist?(layout_path)

    engine = Haml::Engine.new(tpl_data)
    layout = Haml::Engine.new(layout_data) if layout_data

    return layout.render { engine.render } if layout
    engine.render
  end
end
