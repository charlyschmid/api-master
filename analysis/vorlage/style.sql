DEFINE PATH='&1'

DEFINE FILENAME = &PATH/style.css

SET TERMOUT ON
PROMPT Erstelle style.css ...
PROMPT
SET TERMOUT OFF
REM ##################################################################
REM Erstellen der style.css
REM ##################################################################
SPOOL &FILENAME

BEGIN
  db_report_output.text('p,table,td,th { font-family:Courier New; font-size:10pt; }');
  db_report_output.text('body { background-color:white; color:black; font-family:Verdana; font-size:10pt; }');
  db_report_output.text('img { border:0px; }');
  db_report_output.text('table{ empty-cells:show }');
  db_report_output.text('table.header{ width:100%; }');
  db_report_output.text('td,th { border-width:1px; border-color:black; border-style:solid; padding:2px; }');
  db_report_output.text('th {background-color:#aaaaaa;}');
  db_report_output.text('td.header { text-align:left; border-width:0px; border-collapse: collapse; border-style:none; padding:0px; font-family:Verdana; color:#C5000A; font-size:18pt; font-weight:bold; }');
 -- db_report_output.text('td.header_back { text-align:right; border-width:0px; border-style:none; padding:0px; font-family:Verdana; }');
  db_report_output.text('td.header {    text-align: left;    border-width: 0px; border-collapse: collapse;   border-style: none;    padding: 0px;    font-family: Verdana;    color: #FF0000;    font-size: 18pt;    font-weight: bolder;}');

  db_report_output.text('td.data { text-align:right; }');
  db_report_output.text('td.data_bold { text-align:right; font-weight:bold; }');
  db_report_output.text('p.h1 { font-family:Verdana; color:#C5000A; font-size:20pt; font-weight:bold; }');
  db_report_output.text('p.h2 { font-family:Verdana; color:#C5000A; font-size:16pt; font-weight:bold; }');
  db_report_output.text('p.h3 { font-family:Verdana; color:black; font-size:14pt; font-weight:bold; }');
  db_report_output.text('p.footer { font-family:Verdana; font-size:8pt; }');
  db_report_output.text('a.footer { font-size:8pt; }');
  db_report_output.text('a.nav:link { color:black; text-decoration:underline; }');
  db_report_output.text('a.nav:visited { color:gray; text-decoration:underline; }');
  db_report_output.text('a.nav:hover { color:#C5000A; text-decoration:underline; }');
  db_report_output.text('a.nav:active { color:#C5000A; text-decoration:underline; }');
  db_report_output.text('a:link { color:black; text-decoration:underline; }');
  db_report_output.text('a:visited { color:gray; text-decoration:underline; }');
  db_report_output.text('a:hover { color:#C5000A; text-decoration:underline; }');
  db_report_output.text('a:active { color:#C5000A; text-decoration:underline; }');
  db_report_output.text('b.ok { color:darkgreen; }');
  db_report_output.text('b.hinweis { color:orange; }');
  db_report_output.text('b.warning { color:red; }');
  db_report_output.text('li { font-family:Verdana; }');
END;
/
SPOOL OFF

