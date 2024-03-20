function extractPaymentKeys(data) {
    const regex = /Known payment addresses:\s*((?:"[^"]+":\s*z\w+\s*)+)/g;
    let match;
    const keys = [];
    while ((match = regex.exec(data)) !== null) {
        const addresses = match[1].split("\n").filter(Boolean);
        addresses.forEach(address => {
            const [alias, paymentAddress] = address.trim().split(":");
            keys.push(alias.trim());
        });
    }
    return keys;
}

// Example usage:
const data = `
  Alias "koireng" (encrypted):
    Public key hash: 526F32AC4C8A34A23CFA591D9E4704CDC2FD1912
    Public key: tpknam1qq5qe87yjcj2f7gxcvvknutjt0nkkvheuxvhsdwdwzxq63mkmpgeykyyzhq
  Alias "koriengf" (encrypted):
    Public key hash: 2E7018CCF9A53785AFA7CF634941C3E20A2A5840
    Public key: tpknam1qrgazhpdfcwhpjdq4s3dtrqqj7ezzrdzxknks53vm2p52tvfsfw3wa03zwv
  Alias "testingagain" (encrypted):
    Public key hash: 1D16215F261FAF5DD29DFA790A79C8DDE8B9738D
    Public key: tpknam1qp9kyukpqhw46lylq0yzuh0tfkj8llmk25gz3t9mpnl8jyk7cj8qcqp92hx
Known transparent addresses:
  "ethbridge": Internal EthBridge: tnam1quqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqfgdmms
  "ethbridgepool": Internal EthBridgePool: tnam1pqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqu35hpf
Known payment addresses:
  "koriengfpaymentaddress": znam1qp0rqvz2u74kt6zakljceqe2eszfap06fftx3009megnwmwgyt700hyd0y9f5pmegd5hefc0zwkyq
  "testingagainpaymentaddress": znam1qz6n5qnjwcck6c3496v4mm87l7a7hr0qdmxqy9mas9ax7e8k9e24v8t2fkjzwmhx00qs0uq9lkt7y`;

console.log(extractPaymentKeys(data));
