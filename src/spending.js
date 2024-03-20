function extractShieldedKeys(data) {
    const regex = /Alias "(.*?)" \(encrypted\):\s+Viewing Key: z\w+/g;
    let enumeration = 1;
    const keys = [];
    const aliases = data.match(regex);
    if (aliases) {
        aliases.forEach(aliasMatch => {
            const alias = aliasMatch.replace(/Alias "(.*?)" \(encrypted\):\s+Viewing Key: z\w+/, '$1');
            keys.push(`${enumeration}. ${alias}`);
            enumeration++;
        });
    }
    return keys.join('\n');
}



const data = `Known shielded keys:
  Alias "testingagainspendingkeuy" (encrypted):
    Viewing Key: zvknam1qv3h4da8qqqqpq954us06rs80909dc459y0q29xrc2f0ll6nergjjdqalllewxw5dkkpne4crxwnsgmk8sw4k7fynsz0alk54e5n94wf8zctrl0fy3j59gxf8jmg8fdw37m3xhqekj0m68akku92ydvlewf29ea2p3ra4j83tdfy3y2snmhvw5y0q8q2wedyffydtlafl6z85uy57ec89hgglhzrrtct472qhxm0cm40l4k659pypdtszvvnpzeqzdt542x4g29crjczcmm6c
  Alias "koriengfspendkingkey" (encrypted):
    Viewing Key: zvknam1qvv2hsylqqqqpqzq4vqvhvstt662jpjr9geueprn0d44wjlehaxhamvehc9zpryu9dfp0jh6y90yahayah8peq4fg4c2tlytxegmx76t77qjwxpzc8p3f5tlq4t2vy0e0s7ymnyd0hj2ul2f8jhkjll99734vsezvan4ly8nxwv4zh3uk3a75vlctags9wg6l2kemu02lxchddaqdlthedj888k06tlgkcwcgmw04a5suelx6c4n47qx8m8vpue7adjkj4jjz6djgasy6qnlc
  Alias "koirengspendkingkey" (encrypted):
    Viewing Key: zvknam1q0xj3amyqqqqpqz72yq4re602nzmv49phuja06gm5fecern7teghqu6r20npnkcw996zpu2kalgwsg46fkhsk0qu28yh6rrat0jahkw564mr5mqwc40zkde2h5msp0zsrcm0p3dvk52ekpvdv9j8ja47akvlc7uzn80alcqwswjasdfj0mz6330v0cuxhxzzc52gcgkwqvj99u257rx9g0wkmcxx2cjpymmhlf4hshtx8m5xnsp468g93yep8xvcgmpq033g7m0geeg2vtm6x`;

console.log(extractShieldedKeys(data));
