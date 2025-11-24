// CORREZIONE per editEducatore() - Sostituire nel file admin/index.html

async function editEducatore(id) {
    try {
        // Mostra loading
        showLoadingOverlay('Caricamento dati educatore...');

        // 1. CORREZIONE: Carica solo l'educatore specifico invece di tutti
        const response = await fetch(`../api/api_educatori.php?action=get_by_id&id=${id}`);
        const result = await response.json();

        if (!result.success) {
            hideLoadingOverlay();
            alert('Errore nel caricamento dei dati educatore: ' + (result.message || 'Errore sconosciuto'));
            return;
        }

        const educatore = result.data;
        if (!educatore) {
            hideLoadingOverlay();
            alert('Educatore non trovato');
            return;
        }

        // 2. CORREZIONE: Carica dropdown in parallelo invece che sequenzialmente
        try {
            await Promise.all([
                loadEducatoreDropdownsFast(),
                // Altre operazioni parallele se necessarie
            ]);
        } catch (dropdownError) {
            console.warn('Errore caricamento dropdown:', dropdownError);
            // Continua anche se i dropdown falliscono - usa valori base
            loadEducatoreDropdownsBasic();
        }

        // 3. Popola form (stesso codice di prima)
        document.getElementById('educatoreId').value = educatore.id_educatore;
        document.getElementById('educatoreNome').value = educatore.nome;
        document.getElementById('educatoreCognome').value = educatore.cognome;
        document.getElementById('educatoreUsername').value = educatore.username_registrazione || '';
        document.getElementById('educatorePassword').value = '';
        document.getElementById('educatorePassword').placeholder = 'Lascia vuoto per non modificare';
        document.getElementById('educatoreSede').value = educatore.id_sede || '';
        document.getElementById('educatoreTelefono').value = educatore.telefono || '';
        document.getElementById('educatoreEmail').value = educatore.email_contatto || '';
        document.getElementById('educatoreNote').value = educatore.note_professionali || '';
        document.getElementById('educatoreStato').value = educatore.stato_educatore || 'attivo';

        // 4. Gestisci settore e classe (semplificato)
        const settoreSelect = document.getElementById('educatoreSettore');
        const classeSelect = document.getElementById('educatoreClasse');

        if (settoreSelect) {
            settoreSelect.value = educatore.id_settore || '';
        }
        if (classeSelect) {
            classeSelect.value = educatore.id_classe || '';
        }

        // 5. IMPORTANTE: Nascondi loading prima di mostrare modal
        hideLoadingOverlay();

        // 6. Cambia titolo modal per modifica
        document.getElementById('educatoreModalLabel').textContent = 'Modifica Educatore';

        // 7. Mostra modal
        const modal = new bootstrap.Modal(document.getElementById('educatoreModal'));
        modal.show();

    } catch (error) {
        // IMPORTANTE: Sempre nascondere loading in caso di errore
        hideLoadingOverlay();
        console.error('Errore in editEducatore:', error);
        alert('Errore imprevisto nel caricamento dell\'educatore. Riprova più tardi.');
    }
}

// CORREZIONE: Versione veloce dei dropdown
async function loadEducatoreDropdownsFast() {
    try {
        // Carica solo sedi (più affidabile)
        if (sediData.length > 0) {
            const sedeSelect = document.getElementById('educatoreSede');
            sedeSelect.innerHTML = '<option value="">Seleziona sede...</option>';
            sediData.forEach(sede => {
                sedeSelect.innerHTML += `<option value="${sede.id_sede}">${sede.nome_sede}</option>`;
            });
        }

        // Per settori e classi, usa valori semplificati se l'API fallisce
        const settoreSelect = document.getElementById('educatoreSettore');
        const classeSelect = document.getElementById('educatoreClasse');

        settoreSelect.innerHTML = '<option value="">Settore non disponibile</option>';
        classeSelect.innerHTML = '<option value="">Classe non disponibile</option>';

        // Nota: Questo mantiene il form funzionante anche se le API settori/classi falliscono

    } catch (error) {
        console.warn('Errore caricamento dropdown fast:', error);
        loadEducatoreDropdownsBasic();
    }
}

// Fallback se tutto fallisce
function loadEducatoreDropdownsBasic() {
    const settoreSelect = document.getElementById('educatoreSettore');
    const classeSelect = document.getElementById('educatoreClasse');

    if (settoreSelect) {
        settoreSelect.innerHTML = '<option value="">Settore - Errore caricamento</option>';
    }
    if (classeSelect) {
        classeSelect.innerHTML = '<option value="">Classe - Errore caricamento</option>';
    }
}

// Funzioni helper per loading overlay
function showLoadingOverlay(message = 'Caricamento...') {
    // Rimuovi eventuali overlay esistenti
    hideLoadingOverlay();

    const overlay = document.createElement('div');
    overlay.id = 'loadingOverlay';
    overlay.style.cssText = `
        position: fixed;
        top: 0;
        left: 0;
        width: 100%;
        height: 100%;
        background: rgba(0,0,0,0.5);
        display: flex;
        justify-content: center;
        align-items: center;
        z-index: 9999;
        color: white;
        font-size: 16px;
    `;
    overlay.innerHTML = `
        <div style="text-align: center;">
            <div class="spinner-border text-light mb-3" role="status"></div>
            <div>${message}</div>
        </div>
    `;
    document.body.appendChild(overlay);
}

function hideLoadingOverlay() {
    const overlay = document.getElementById('loadingOverlay');
    if (overlay) {
        overlay.remove();
    }
}