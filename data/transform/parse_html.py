import re
import csv
import pandas as pd
from bs4 import BeautifulSoup


def cull_html(input_file):
    cull = []
    soup = BeautifulSoup(open(input_file))

    # get all of the ps and h2s in the document
    p_h2s = soup.find_all(['h2', 'p'])
    output_clean(p_h2s)

    for p_h2 in p_h2s:
        # ignore the footnotes
        css_class = p_h2.get('class')
        if css_class and 'sdfootnote' not in css_class:
            cull.append(re.sub(r'(\/)\s', '\1', p_h2.text.replace('\n', ' ')))

    return cull

def output_clean(tags_in):
    somehtml = ''
    outhtml = open('parsed.html', 'wb')

    pro_opp_pattern = re.compile(
        r'''
        (\[?
        (?:(?:CA|US|VN|PE|BN|NZ|AU|MX|SG|MY|CL|JP)
        (?:\/*\]?\s*))+
        )
        (
        .+?
        (?=\[|\]|CA|US|VN|PE|BN|NZ|AU|MX|SG|MY|CL|JP)
        \]?
        )
        ''',
        re.UNICODE | re.VERBOSE | re.DOTALL | re.MULTILINE)

    firstp = True

    for tag in tags_in:
        if tag.name != 'h2':
            row = tag.text
            m = pro_opp_pattern.findall(row)
            if m:
                print len(m)
                somehtml += '</p>'
                rowhtml = ''
                firstp = True
                for match in m:
                    groups = match
                    countries = re.sub(r'(\/|\s|\[|\])', ' ', groups[0]).strip()
                    spantag = ' <span class="countries ' + countries + '">' + groups[0] + '</span>' + groups[1]
                    rowhtml += spantag

                somehtml += ''.join(['<p>', rowhtml, '</p>'])
            else:
                if len(row) > 1:
                    if firstp:
                        somehtml += '<p>' + row
                        firstp = False
                    else:
                        somehtml += row

        else:
            somehtml += '<h2>' + tag.text + '</h2>' + '\n'

    outhtml.write(somehtml.encode('utf8'))
    outhtml.close()
    
def parse_html(html_in):
    parsed = '\n'.join(cull_html(html_in))
    # this pattern appears to catch all the decisions, as well as the subsequent word (if there is one)

    pro_opp_pattern = re.compile(
        r'''
        (
        (?:(?:CA|US|VN|PE|BN|NZ|AU|MX|SG|MY|CL|JP)
        (?:\/*))+
        \]*\s*
        )
        (\w+)?
        (
        .+?
        (?:\[|\]|CA|US|VN|PE|BN|NZ|AU|MX|SG|MY|CL|JP)?
        )
        ''',
        re.UNICODE | re.VERBOSE)

    matches = pro_opp_pattern.finditer(parsed)
    d = []

    for m in matches:
        groups = m.groups()
        stance = groups[1].lower() if groups[1] else 'none'
        countries = m.groups()[0].replace('//', '/').replace(']', '')
        countries = [s.strip() for s in countries.split('/') if s.strip() != '']
        countries = '/'.join(countries)
        para = groups[0] + stance + groups[2]

        row = {
            'countries': countries,
            'stance': stance,
            'para': para
        }

        d.append(row)

    return pd.DataFrame.from_records(d)
