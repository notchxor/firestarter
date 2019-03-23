cp config-file node/config.ini
BPS="aaablockprod bbbblockprod cccblockprod dddblockprod eeeblockprod fffblockprod gggblockprod hhhblockprod iiiblockprod jjjblockprod kkkblockprod lllblockprod mmmblockprod nnnblockprod ooobloc    kprod pppblockprod qqqblockprod rrrblockprod sssblockprod tttblockprod uuublockprod vvvblockprod wwwblockprod devdevdevdev xxxblockprod yyyblockprod zzzblockprod tstblockprod"


for bp in $BPS;do
        echo producer-name=$bp >> node/config.ini

done

echo signature-provider=EOS7HWfNo5DHkWndg48xQfn5EGBvz3XxoveCtjQ2GHVmAg5ibZRNN=KEY:5J4gZSeebvRK7ZFxcL4WqV4Lhttm7453B6duCGxYjC6DM9SN6uu >> node/config.ini
echo signature-provider=EOS6MRyAjQq8ud7hVNYcfnVPJqcVpscN5So8BhtHuGYqET5GDW5CV=KEY:5KQwrPbwdL6PhXujxW37FSSQZ1JiwsST4cqQzDeyXtP79zkvFD3 >> node/config.ini
