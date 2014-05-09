from wsgiref.simple_server import make_server

from pyramid.config import Configurator
from pyramid.view import view_config
from scipy import misc
import os
from pyramid.static import static_view


# This acts as the view function
def lena(request):
    return misc.lena().tolist()


def home(request):
    return {"folder": os.path.abspath(".")}


def main():
    # Grab the config, add a view, and make a WSGI app
    config = Configurator()
    config.include('pyramid_chameleon')
    config.add_static_view(name='static', path=os.path.abspath("."))
    config.add_route("home", "/")
    config.add_route("lena", "/lena")
    config.add_view(home, route_name="home",
                    renderer=os.path.abspath("template.pt"))
    config.add_view(lena, route_name="lena", renderer="json")
    app = config.make_wsgi_app()
    return app

if __name__ == '__main__':
    # When run from command line, launch a WSGI server and app
    app = main()
    server = make_server('0.0.0.0', 8080, app)
    server.serve_forever()
