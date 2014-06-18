require 'hobbit'
require 'hobbit/contrib'
require 'nokogiri'
require 'open-uri'

Equipo = Struct.new(:nombre, :puntos, :partidos, :ganados, :empatados, :perdidos, :goles_favor, :goles_contra, :diferencia) do
  def puntos_sobre_partidos
    puntos.fdiv(partidos)
  end
  
  def ganados_sobre_partidos
    ganados.fdiv(partidos)
  end

  def diferencia_partidos
    diferencia.fdiv(partidos)
  end

  def goles_favor_sobre_partidos
    goles_favor.fdiv(partidos)
  end
end


class App < Hobbit::Base
  include Hobbit::Render
  
  use Rack::Static, root: 'public', urls: ['/css']

  get '/' do
    equipos=[]
    punteros=[]
    urls = [ "http://www.ahba.com.ar/clubes/index.php?accion=mostrar_tabla_posiciones&sector=damas&categoria=Campeonato&id_torneo=61",      "http://www.ahba.com.ar/clubes/index.php?accion=mostrar_tabla_posiciones&sector=damas&categoria=Campeonato&id_torneo=68","http://www.ahba.com.ar/clubes/index.php?accion=mostrar_tabla_posiciones&sector=damas&categoria=Campeonato&id_torneo=143","http://www.ahba.com.ar/clubes/index.php?accion=mostrar_tabla_posiciones&sector=damas&categoria=Campeonato&id_torneo=150","http://www.ahba.com.ar/clubes/index.php?accion=mostrar_tabla_posiciones&sector=damas&categoria=Campeonato&id_torneo=157"]
    
    urls.each do |url|
      @doc = Nokogiri::HTML(open(url))
      cells = @doc.css('html body table tr td div.aplicacion table.showpanel tbody tr').search('tr')[0..-1]
      
      first = true
      cells.each do |cell|
        equipo = Equipo.new(cell.search('td')[0].text, cell.search('td')[1].text.to_i, cell.search('td')[2].text.to_i, cell.search('td')[3].text.to_i, cell.search('td')[4].text.to_i, cell.search('td')[5].text.to_i, cell.search('td')[7].text.to_i, cell.search('td')[8].text.to_i, cell.search('td')[9].text.to_i)
        
        if first
          punteros << equipo
          first = false
        else
          equipos <<  equipo
        end
      end
    end
    @punteros = punteros.sort_by{|equipo| [-equipo.puntos_sobre_partidos, -equipo.ganados_sobre_partidos, -equipo.diferencia_partidos, -equipo.goles_favor_sobre_partidos ] }
    @equipos = equipos.sort_by{|equipo| [-equipo.puntos_sobre_partidos, -equipo.ganados_sobre_partidos, -equipo.diferencia_partidos, -equipo.goles_favor_sobre_partidos ] }

    render 'index'
  end
end