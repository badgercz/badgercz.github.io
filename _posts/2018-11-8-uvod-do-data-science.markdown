---
layout: post
title:  "Jemný úvod do datové vědy"
date:   2018-11-08 17:38:03 +0200
categories: programovani python
---

V tomto článku bych rád představil základní metody *web-scrapingu* a následného zpracování získaných dat pomocí nástroje `jupyter notebook`. Článek je určený pro programováním lehce políbené jedince a je prakticky zaměřený.

Je potřeba sehnat potřebné nástroje. Velmi doporučuji celý balík [`Anaconda`](https://www.anaconda.com/), který je pro podobné účely určen. Instalace by měla proběhnout bez problémů. Kdyžtak se ptejte [zde](google.com) nebo mi napište a třeba vám pomůžu. Asi nemá smysl popisovat ovládání Jupyteru, k tomu slouží podrobná [dokumentace](https://jupyter-notebook.readthedocs.io/en/stable/notebook.html).

## Úkol
Řekněme, že chceme zobrazit informace o obcích v okrese Rokycany. Stáhnout někde připravená data je příliš jednoduchý úkol a nebyly by vysvětleny základy *web-scrapingu*. Každý takový úkol začíná hledáním informací. Obvykle může jít o nějakou veřejnou databázi, články apod. V našem případě to bude *Wikipedie*, což úkol možná trošku zlehčuje, protože její stránky jsou výborně strukturované. 

Nejdříve tedy stáhneme potřebná data.

``` python
from bs4 import BeautifulSoup
import requests

urls = ['/wiki/Dob%C5%99%C3%ADv']
dobriv = requests.get("https://cs.wikipedia.org" + urls[0])
soup = BeautifulSoup(dobriv.text, 'html.parser')

for link in soup.find_all("td", {"class": "navbox-list"})[1].div.find_all("a"):
    try:
        urls.append(link["href"])
    except:
        continue
```

Nejdříve si do *listu* uložíme semínko, ze kterého prorosteme do kýžených ostatních stránek. Zvolil jsem náhodně Dobřív. Pokud se podíváte na strukturu stránky, vidíte dole v boxu ostatní obce. 

![Screenshot](/assets/dobrivwiki.png)

Pomocí vývojářských nástrojů v prohlížeči (`F12`) najedeme na box. Vlevo se promítne struktura. Je vidět, že seznam obcí je pod elementem `td` specifikovaným pomocí `class="navbox-list"`. V `Jupyteru` se průběžně můžete koukat, jak stažená data vypadají a podle toho *těžit*. V zásadě obvykle stačí relativně malá sada příkazů, více se dočtete v dokumantaci k balíčku `bs4`.

Máme tedy všechny adresy. Nyní *scrapneme* kýžené informace. V zásadě projedeme *list* `urls` a pro každý prvek vytvoříme *request*, z něj vesele uložíme požadované informace a pokračujeme dál až do konce. Následující kód tedy nejspíše nikoho nepřekvapí. 

``` python


```
