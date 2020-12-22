target: serverUseThreadPool.cpp HandleClient.o server.cpp HandleServer.o client.cpp global.cpp HandleServerUseThreadPool.o serverV2.cpp HandleServerV2.o
	#g++ -o server server.cpp HandleServer.cpp HandleClient.o global.cpp  -lmysqlclient -lpthread
	g++ -g -o serverUseThreadPool serverUseThreadPool.cpp HandleServerUseThreadPool.o global.cpp -lmysqlclient -lpthread -lhiredis
	g++ -o server server.cpp HandleServer.o global.cpp -lmysqlclient -lpthread -lhiredis
	g++ -o client client.cpp HandleClient.o -lpthread
	g++ -o serverV2 serverV2.cpp  HandleServerV2.o global.cpp -lmysqlclient -lpthread -lhiredis

HandleServerV2.o:HandleServerV2.cpp global.cpp
	g++ -c HandleServerV2.cpp global.cpp -lmysqlclient -lpthread -lhiredis

HandleServerUseThreadPool.o: HandleServerUseThreadPool.cpp global.cpp
	g++ -c HandleServerUseThreadPool.cpp global.cpp -lmysqlclient -lpthread -lhiredis

HandleServer.o: HandleServer.cpp global.cpp
	g++ -c HandleServer.cpp global.cpp -lmysqlclient -lpthread -lhiredis

HandleClient.o:	HandleClient.cpp
	g++ -c HandleClient.cpp

clean:
	rm server
	rm client
	rm *.o
