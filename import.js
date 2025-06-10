const admin = require('firebase-admin');
const fs = require('fs');
const path = require('path');

// Inicializar Firebase Admin SDK
admin.initializeApp({
  projectId: 'geek-arise',
  // Se precisar de credenciais específicas, descomente e configure:
  // credential: admin.credential.cert(require('./serviceAccountKey.json'))
});

const db = admin.firestore();

async function importarProdutos() {
  try {
    // Ler o arquivo JSON
    const filePath = path.join(__dirname, 'assets', 'meus_produtos.json');
    const jsonData = fs.readFileSync(filePath, 'utf8');
    const produtos = JSON.parse(jsonData);
    
    console.log(`Encontrados ${produtos.length} produtos para importar...`);
    
    // Mostrar uma amostra dos dados
    console.log('Exemplo de produto:', produtos[0]);
    
    // Importar em lotes de 500 (limite do Firestore)
    const batchSize = 500;
    let importedCount = 0;
    
    for (let i = 0; i < produtos.length; i += batchSize) {
      const batch = db.batch();
      const currentBatch = produtos.slice(i, i + batchSize);
      
      currentBatch.forEach(produto => {
        // Criar um novo documento com ID automático
        const docRef = db.collection('produtos').doc();
        batch.set(docRef, produto);
      });
      
      // Executar o lote
      await batch.commit();
      importedCount += currentBatch.length;
      
      console.log(`Importados ${importedCount}/${produtos.length} produtos...`);
    }
    
    console.log('✅ Importação concluída com sucesso!');
    
  } catch (error) {
    console.error('❌ Erro durante a importação:', error);
  } finally {
    // Finalizar a aplicação
    process.exit();
  }
}

// Executar a importação
importarProdutos();