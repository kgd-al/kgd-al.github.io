console.log("[kgd-debug] Starting...")

const citations = document.getElementsByClassName('citation-span');
// console.log("citations:", citations)
for (let i=0; i<citations.length; i++) {
    let citation = citations[i]
    let ct_id = citation.getAttribute("target-ctid")

    let tooltip = document.getElementById(ct_id)
    let bibitems = tooltip.getElementsByTagName("li")
    let cwidths = [...bibitems].map((o) => o.getAttribute("value").length)
    let cwidth = cwidths.reduce((a, b) => Math.max(a, b), 0)
    cwidth = 0.5 + Math.max(1.5, cwidth)

    // console.log(i, "cwidth:", cwidth)

    tooltip.style.width = (40+cwidth) + "em"
    // let list = tooltip.getElementsByTagName("ol")[0]
    // list.style.marginLeft = cwidth + "em"

    citation.addEventListener('mouseenter', evt => {
        console.log("Mouse entered", citation, tooltip)
        let sbr = citation.getBoundingClientRect();
        // console.log("==", i, "=====")
        console.log(window.innerWidth)
        console.log(window.scrollX, window.scrollY)
        console.log("sbr:", sbr)

        // let x = sbr.left
        // let y = sbr.top
        let x = window.scrollX + sbr.left
        let y = window.scrollY + sbr.top

        tooltip.style.display = 'inline-block'
        let tbr = tooltip.getBoundingClientRect()
        let overflow = "100vw - " + x + "px - " + tbr.width + "px"
        // console.log("tbr:", tbr)
        // console.log("overflow:", overflow)
        tooltip.style.right = "max(1em, " + overflow + ")"
        // tooltip.style.left = "0";
        tooltip.style.top = y + "px"
        console.log(tooltip.style.right, tooltip.style.top)
        // console.log(tooltip)
    });

    // tooltip.addEventListener('mouseleave', evt => {
    //     tooltip.style.display = 'none'
    //     console.log("Mouse left", tooltip)
    // })
}

console.log("[kgd-debug] Monitoring")
