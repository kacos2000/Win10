*Continued from [keywords2.md](keywords2.md)*<br>
[keywords.md](keywords.md)*<br>
### Event log 'Keywords' *p3*

Powershell script to get a more complete list *(from all event logs)*:

        # List all event Log providers:
        $pnames = @((Get-WinEvent -ListLog * -ErrorAction SilentlyContinue).ProviderName|sort -unique)
        $pcount = $pnames.count
        $c=0
        $kw=@()
        $listprovider=@()

        $keyword = foreach($p in $pnames){$c++;
                        write-progress -activity "List provider:$($p) ->  $($c) of $($pcount)"  -PercentComplete (($c / $($pcount)) * 100)

                        # For each 'Listprovider' name get the keyword names & descriptions for that provider
                        if(((Get-WinEvent -Listprovider $p -ErrorAction SilentlyContinue).events|select-object -property id, keywords) -ne $null)
                            {$listprovider = @((Get-WinEvent -Listprovider $p -ErrorAction SilentlyContinue).events|select-object -property id, keywords)


                            foreach($i in $listprovider){
                            $kn=$vd=$vdn=$null
                            #Get all possible keyword values (decimal) for each provider's EventId, and add them together        

                                $kvv=0;$n=$d=0
                                foreach($m in $i.keywords) {$mc=0; $mc += $m.value.count -1     
                                                                                            $kvv +=  $m.value[$mc]
                                                                                            $vd  += "$($m.value[$mc]). "

                                                     if($i.keywords.name.count -ne 0){$kn  += "$($i.keywords.name[$n]). ";$n++}
                                                     if($i.keywords.displayname.count -ne 0){$vdn += "$($i.keywords.displayname[$d]). ";$d++}
                                                                                            } 

                            [PSCustomObject]@{
                                Provider = $p
                                EventID = $i.id
                                '#' = $i.keywords.value.count
                                ValueHEX = "0x"+'{0:x16}'-f $kvv
                                ValueDEC= $vd
                                Name = $kn
                                Displayname = $vdn
                                }
                          }  
                    }
        }


        $keyword = $keyword|sort -property ValueHEX, '#',ValueDEC -unique 
        $keyword|Out-GridView -PassThru
        $keyword|Export-Csv -path "$($env:userprofile)\desktop\keyall.csv" -Delimiter ","


[Output in CSV from 700+ EventLog List providers](https://github.com/kacos2000/Win10/blob/master/EventLogs/keyall.csv)<br>




_______________________________________________________________________________________

1. [keywords.md](keywords.md)<br>
2. [keywords2.md](keywords2.md)<br>
2. [OpCodes.md](OpCodes.md)<br>
