# Awesome Elixir Mirror

## Start

```sh
docker-compose up -d
```

Navigate to http://localhost:4000/

It takes a while for the app to fetch GitHub data for the first time, so you can browse http://104.248.142.159:4000 while it fetches

## Stop

```sh
docker-compose down
```

## Supervision tree

![diagram](lol.png)

## Test coverage

```
  0.0% lib/awesome.ex                                  9        0        0
 75.0% lib/awesome/application.ex                     29        4        1
  0.0% lib/awesome/release.ex                         18        5        5
  0.0% lib/awesome/repo.ex                             5        0        0
  0.0% lib/awesome_web.ex                             62        1        1
100.0% lib/awesome_web/controllers/page_control       23        4        0
  0.0% lib/awesome_web/endpoint.ex                    27        0        0
  0.0% lib/awesome_web/gettext.ex                     24        0        0
100.0% lib/awesome_web/router.ex                      14        2        0
  0.0% lib/awesome_web/views/error_helpers.ex         44        5        5
100.0% lib/awesome_web/views/error_view.ex            16        1        0
  0.0% lib/awesome_web/views/layout_view.ex            3        0        0
100.0% lib/awesome_web/views/page_view.ex             34        5        0
100.0% lib/database.ex                                79       14        0
100.0% lib/github.ex                                  33        6        0
100.0% lib/http.ex                                    17        3        0
100.0% lib/markdown.ex                                73       17        0
 81.8% lib/refresh.ex                                105       22        4
100.0% lib/types.ex                                   42        4        0
100.0% test/support/conn_case.ex                      38        4        0
 42.9% test/support/data_case.ex                      53        7        4
[TOTAL]  80.8%
```
